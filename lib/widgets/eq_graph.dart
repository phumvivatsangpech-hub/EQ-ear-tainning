import 'package:flutter/material.dart';
import '../models/eq_band.dart';
import 'eq_painter.dart';
import 'dart:math';

class EqGraph extends StatefulWidget {
  final List<EqBand> bands;
  final Function(List<EqBand>) onBandsChanged;
  final bool interactive;
  final String filterType;

  const EqGraph({
    Key? key,
    required this.bands,
    required this.onBandsChanged,
    this.interactive = true,
    this.filterType = 'bell',
  }) : super(key: key);

  @override
  State<EqGraph> createState() => _EqGraphState();
}

class _EqGraphState extends State<EqGraph> {
  int? _draggingIndex;

  // คำนวณตำแหน่ง Y ของ node ให้ตรงกับที่วาดใน EqPainter
  double _getNodeY(EqBand band, Size size) {
    if (widget.filterType == 'lowpass' || widget.filterType == 'highpass') {
      return (1 - (-3 + 12) / 24) * size.height; // -3dB point
    }
    return (1 - (band.gain + 12) / 24) * size.height;
  }

  int? _findNearestNode(Offset position, Size size) {
    double minDistance = 30;
    int? nearestIndex;

    for (int i = 0; i < widget.bands.length; i++) {
      EqBand band = widget.bands[i];

      double logMin = log(20);
      double logMax = log(20000);
      double nodeX = (log(band.frequency) - logMin) /
                     (logMax - logMin) * size.width;
      double nodeY = _getNodeY(band, size); // ใช้ตำแหน่ง Y ที่ถูกต้อง

      double distance = sqrt(
        pow(position.dx - nodeX, 2) + pow(position.dy - nodeY, 2)
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }
    return nearestIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          Size size = Size(constraints.maxWidth, constraints.maxHeight);

          return GestureDetector(
            onPanStart: widget.interactive
                ? (details) {
                    setState(() {
                      _draggingIndex = _findNearestNode(
                        details.localPosition,
                        size,
                      );
                    });
                  }
                : null,

            onPanUpdate: widget.interactive
                ? (details) {
                    if (_draggingIndex == null) return;

                    setState(() {
                      List<EqBand> newBands = List<EqBand>.from(widget.bands);

                      double newFreq = EqPainter.xToFreq(
                        details.localPosition.dx,
                        size.width,
                      );
                      double newGain = EqPainter.yToGain(
                        details.localPosition.dy,
                        size.height,
                      );

                      // Low/High Pass ลากได้แค่แนวนอน (frequency เท่านั้น)
                      if (widget.filterType == 'lowpass' ||
                          widget.filterType == 'highpass') {
                        newBands[_draggingIndex!] = newBands[_draggingIndex!]
                            .copyWith(frequency: newFreq);
                      } else {
                        newBands[_draggingIndex!] = newBands[_draggingIndex!]
                            .copyWith(
                          frequency: newFreq,
                          gain: newGain,
                        );
                      }

                      widget.onBandsChanged(newBands);
                    });
                  }
                : null,

            onPanEnd: widget.interactive
                ? (details) {
                    setState(() {
                      _draggingIndex = null;
                    });
                  }
                : null,

            child: CustomPaint(
              painter: EqPainter(
                bands: widget.bands,
                size: size,
                filterType: widget.filterType,
              ),
              size: size,
            ),
          );
        },
      ),
    );
  }
}