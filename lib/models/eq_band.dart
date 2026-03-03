class EqBand {
  double frequency; // ความถี่ เช่น 1000 คือ 1kHz
  double gain;      // ระดับเสียง +12 ถึง -12 dB
  double q;         // ความแคบ/กว้างของ band

  EqBand({
    required this.frequency,
    required this.gain,
    required this.q,
  });

  // คัดลอก EqBand และเปลี่ยนค่าบางอย่าง
  EqBand copyWith({
    double? frequency,
    double? gain,
    double? q,
  }) {
    return EqBand(
      frequency: frequency ?? this.frequency,
      gain: gain ?? this.gain,
      q: q ?? this.q,
    );
  }
}

