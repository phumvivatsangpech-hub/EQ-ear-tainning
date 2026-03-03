import 'package:flutter/material.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'บทเรียน Frequency',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFreqCard(
            title: 'Sub Bass',
            range: '20 Hz - 60 Hz',
            description: 'เสียงที่ต่ำมากจนรู้สึกได้มากกว่าได้ยิน '
                'พบในเสียงกลองใหญ่และเบสหนักๆ '
                'ถ้ามากเกินไปจะทำให้เสียงขุ่นและหนักอึ้ง',
            color: Colors.red,
            icon: Icons.vibration,
          ),
          const SizedBox(height: 12),
          _buildFreqCard(
            title: 'Bass',
            range: '60 Hz - 250 Hz',
            description: 'เสียงเบสที่ได้ยินชัดเจน พบในเบสกีตาร์ '
                'และเสียงต่ำของนักร้อง ให้ความอบอุ่นกับเสียง '
                'ถ้ามากเกินไปจะทำให้เสียงทื่อและขาดความชัด',
            color: Colors.orange,
            icon: Icons.music_note,
          ),
          const SizedBox(height: 12),
          _buildFreqCard(
            title: 'Low Mid',
            range: '250 Hz - 500 Hz',
            description: 'ย่านที่ทำให้เสียงอู้อี้หรือทึบ '
                'มักถูกตัดออกในการ mix เพื่อให้เสียงโปร่งขึ้น '
                'พบในเสียงกีตาร์และเปียโน',
            color: Colors.yellow,
            icon: Icons.equalizer,
          ),
          const SizedBox(height: 12),
          _buildFreqCard(
            title: 'Mid',
            range: '500 Hz - 2 kHz',
            description: 'ย่านที่หูมนุษย์ไวที่สุด เสียงพูดและเสียงร้อง '
                'อยู่ในย่านนี้เป็นหลัก การ boost ตรงนี้ทำให้เสียงแหลม '
                'และเจ็บหูได้ง่าย',
            color: Colors.green,
            icon: Icons.hearing,
          ),
          const SizedBox(height: 12),
          _buildFreqCard(
            title: 'Upper Mid',
            range: '2 kHz - 6 kHz',
            description: 'ย่านที่ทำให้เสียงชัดและคม '
                'การ boost ตรงนี้ทำให้ได้ยินเสียงชัดขึ้น '
                'แต่ถ้ามากเกินจะทำให้เสียงแสบหู',
            color: Colors.teal,
            icon: Icons.graphic_eq,
          ),
          const SizedBox(height: 12),
          _buildFreqCard(
            title: 'Presence',
            range: '6 kHz - 10 kHz',
            description: 'ย่านที่ทำให้เสียงมีความชัดเจนและสด '
                'การ boost ตรงนี้ทำให้เสียงร้องดูอยู่หน้ามิกซ์ '
                'และฟังดูใกล้หูมากขึ้น',
            color: Colors.blue,
            icon: Icons.surround_sound,
          ),
          const SizedBox(height: 12),
          _buildFreqCard(
            title: 'Brilliance',
            range: '10 kHz - 20 kHz',
            description: 'ย่านเสียงสูงสุดที่ได้ยิน ให้ความสดใสและประกาย '
                'กับเสียง พบในเสียงฉาบและเสียง air ของเสียงร้อง '
                'ถ้ามากเกินจะทำให้เสียงแหลมเกินไป',
            color: Colors.purple,
            icon: Icons.star,
          ),
        ],
      ),
    );
  }

  Widget _buildFreqCard({
    required String title,
    required String range,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        range,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}