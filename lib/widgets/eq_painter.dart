import 'package:flutter/material.dart';
import '../models/eq_band.dart';
import 'dart:math';

class EqPainter extends CustomPainter {
  final List<EqBand> bands;
  final List<EqBand>? answerBands;
  final List<double>? fftData;
  final Size size;
  final String filterType;

  EqPainter({
    required this.bands,
    this.answerBands,
    this.fftData,
    required this.size,
    this.filterType = 'bell',
  });

  double freqToX(double freq) {
    double logMin = log(20);
    double logMax = log(20000);
    double logFreq = log(freq);
    return (logFreq - logMin) / (logMax - logMin) * size.width;
  }

  double gainToY(double gain) {
    return (1 - (gain + 12) / 24) * size.height;
  }

  static double xToFreq(double x, double width) {
    double logMin = log(20);
    double logMax = log(20000);
    double logFreq = logMin + (x / width) * (logMax - logMin);
    return exp(logFreq).clamp(20.0, 20000.0);
  }

  static double yToGain(double y, double height) {
    return ((1 - y / height) * 24 - 12).clamp(-12.0, 12.0);
  }

  double _calculateTotalGain(double freq, List<EqBand> targetBands) {
    double totalGain = 0;

    for (EqBand band in targetBands) {
      switch (filterType) {
        case 'lowpass':
          double ratio = freq / band.frequency;
          double steepness = band.q * 2 + 2;
          double db = -12.0 * log(1 + pow(ratio, steepness)) / log(2);
          totalGain += db.clamp(-12.0, 0.0);
          break;

        case 'highpass':
          double ratio = band.frequency / freq;
          double steepness = band.q * 2 + 2;
          double db = -12.0 * log(1 + pow(ratio, steepness)) / log(2);
          totalGain += db.clamp(-12.0, 0.0);
          break;

        case 'bell':
        case 'multi':
        default:
          double logFreq = log(freq);
          double logCenter = log(band.frequency);
          double distance = logFreq - logCenter;
          double influence = band.gain * exp(-distance * distance * band.q * 2);
          totalGain += influence;
          break;
      }
    }

    return totalGain.clamp(-12.0, 12.0);
  }

  // คำนวณตำแหน่ง Y ของ node สำหรับ lowpass/highpass
  double _getNodeY(EqBand band) {
    if (filterType == 'lowpass' || filterType == 'highpass') {
      // Node อยู่ที่ -3dB point เสมอ
      return gainToY(-3);
    }
    return gainToY(band.gain);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawLabels(canvas, size);
    
    if (fftData != null) {
      _drawSpectrum(canvas, size);
    }

    if (answerBands != null) {
      // Draw Answer Background
      _drawCurve(canvas, size, answerBands!, Colors.greenAccent, 3);
      _drawNodes(canvas, size, answerBands!, Colors.green, true);
      
      // Draw User Answer (dimmed slightly)
      _drawCurve(canvas, size, bands, Colors.yellow.withOpacity(0.5), 2);
      _drawNodes(canvas, size, bands, Colors.orange.withOpacity(0.5), false);
    } else {
      // Normal state
      _drawCurve(canvas, size, bands, Colors.yellow, 2);
      _drawNodes(canvas, size, bands, Colors.orange, true);
    }
  }

  void _drawSpectrum(Canvas canvas, Size size) {
    if (fftData == null || fftData!.isEmpty) return;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.blue.withOpacity(0.0),
          Colors.blue.withOpacity(0.1),
          Colors.blue.withOpacity(0.3),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    const int points = 120;
    for (int i = 0; i <= points; i++) {
      double x = (i / points) * size.width;
      double freq = xToFreq(x, size.width);
      
      // Nyquist is around 22050 usually.
      double binIndex = (freq / 22050.0) * 256.0;
      int idx = binIndex.floor().clamp(0, 255);
      int nextIdx = (idx + 1).clamp(0, 255);
      double fraction = binIndex - idx;
      
      double val = fftData![idx] * (1 - fraction) + (fftData!.length > nextIdx ? fftData![nextIdx] : fftData![idx]) * fraction;
      
      // FFT values can be boosted for visualization
      double scaledHeight = val * size.height * 2.5; 
      double y = size.height - scaledHeight.clamp(0, size.height);
      
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Subtle outline for the spectrum
    final linePaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final linePath = Path();
    for (int i = 0; i <= points; i++) {
      double x = (i / points) * size.width;
      double freq = xToFreq(x, size.width);
      double binIndex = (freq / 22050.0) * 256.0;
      int idx = binIndex.floor().clamp(0, 255);
      int nextIdx = (idx + 1).clamp(0, 255);
      double fraction = binIndex - idx;
      double val = fftData![idx] * (1 - fraction) + (fftData!.length > nextIdx ? fftData![nextIdx] : fftData![idx]) * fraction;
      double scaledHeight = val * size.height * 2.5;
      double y = size.height - scaledHeight.clamp(0, size.height);
      if (i == 0) linePath.moveTo(x, y); else linePath.lineTo(x, y);
    }
    canvas.drawPath(linePath, linePaint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    List<double> dbLines = [-12, -6, 0, 6, 12];
    for (double db in dbLines) {
      double y = gainToY(db);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    List<double> freqLines = [
      20, 50, 100, 200, 500,
      1000, 2000, 5000, 10000, 20000
    ];
    for (double freq in freqLines) {
      double x = freqToX(freq);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.white.withOpacity(0.5),
      fontSize: 10,
    );

    Map<double, String> freqLabels = {
      20: '20',
      50: '50',
      100: '100',
      200: '200',
      500: '500',
      1000: '1k',
      2000: '2k',
      5000: '5k',
      10000: '10k',
      20000: '20k',
    };

    freqLabels.forEach((freq, label) {
      double x = freqToX(freq);
      _drawText(canvas, label, Offset(x - 10, size.height - 15), textStyle);
    });

    Map<double, String> dbLabels = {
      12: '+12',
      6: '+6',
      0: '0',
      -6: '-6',
      -12: '-12',
    };

    dbLabels.forEach((db, label) {
      double y = gainToY(db);
      _drawText(canvas, label, Offset(4, y - 6), textStyle);
    });
  }

  void _drawCurve(Canvas canvas, Size size, List<EqBand> targetBands, Color color, double strokeWidth) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool started = false;

    for (double x = 0; x <= size.width; x += 1) {
      double freq = xToFreq(x, size.width);
      double totalGain = _calculateTotalGain(freq, targetBands);
      double y = gainToY(totalGain);

      if (!started) {
        path.moveTo(x, y);
        started = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawNodes(Canvas canvas, Size size, List<EqBand> targetBands, Color innerColor, bool drawLabels) {
    for (EqBand band in targetBands) {
      double x = freqToX(band.frequency);
      double y = _getNodeY(band);

      final outerPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 14, outerPaint);

      final innerPaint = Paint()
        ..color = innerColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 10, innerPaint);

      if (drawLabels) {
        String freqLabel = band.frequency >= 1000
            ? '${(band.frequency / 1000).toStringAsFixed(1)} kHz'
            : '${band.frequency.toStringAsFixed(0)} Hz';

        String gainLabel = band.gain >= 0
            ? '+${band.gain.toStringAsFixed(1)} dB'
            : '${band.gain.toStringAsFixed(1)} dB';

        if (filterType == 'lowpass' || filterType == 'highpass') {
          _drawText(
            canvas,
            freqLabel,
            Offset(x - 20, y - 30),
            const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          );
        } else {
          _drawText(
            canvas,
            freqLabel,
            Offset(x - 20, y - 42),
            const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          );
          _drawText(
            canvas,
            gainLabel,
            Offset(x - 20, y - 28),
            TextStyle(
              color: band.gain >= 0 ? Colors.greenAccent : Colors.redAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          );
        }
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(EqPainter oldDelegate) => true;
}