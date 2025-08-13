import 'package:flutter/material.dart';
import 'card.dart';
import 'model/pelajaran.dart';
import 'addButton.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Map<String, List<Pelajaran>> jadwal = {};
  bool isLoading = false;

  final List<String> hariList = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    final dummyData = {
      'Senin': [
        Pelajaran(
          id: 1,
          nama: 'Matematika',
          jam: '08:00 - 09:30',
          warna: Colors.blue,
          namaHari: 'Senin',
          waktuMulai: '08:00',
          waktuSelesai: '09:30',
        ),
        Pelajaran(
          id: 2,
          nama: 'Fisika',
          jam: '10:00 - 11:30',
          warna: Colors.red,
          namaHari: 'Senin',
          waktuMulai: '10:00',
          waktuSelesai: '11:30',
        ),
      ],
      'Selasa': [
        Pelajaran(
          id: 3,
          nama: 'Bahasa Inggris',
          jam: '09:00 - 10:30',
          warna: Colors.green,
          namaHari: 'Selasa',
          waktuMulai: '09:00',
          waktuSelesai: '10:30',
        ),
      ],
      'Rabu': [
        Pelajaran(
          id: 4,
          nama: 'Kimia',
          jam: '08:30 - 10:00',
          warna: Colors.purple,
          namaHari: 'Rabu',
          waktuMulai: '08:30',
          waktuSelesai: '10:00',
        ),
        Pelajaran(
          id: 5,
          nama: 'Biologi',
          jam: '13:00 - 14:30',
          warna: Colors.teal,
          namaHari: 'Rabu',
          waktuMulai: '13:00',
          waktuSelesai: '14:30',
        ),
      ],
    };

    setState(() {
      jadwal = dummyData;
    });
  }

  void _onScheduleAdded() {
    // For demo purposes, we'll just reload the dummy data
    _loadDummyData();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFfaf3f4),
          child: RefreshIndicator(
            onRefresh: () async => _loadDummyData(),
            child: _buildContent(),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: AddButton(onScheduleAdded: _onScheduleAdded),
        ),
      ],
    );
  }

  Widget _buildContent() {
    // Check if all schedules are empty
    final hasAnySchedule = jadwal.values.any((list) => list.isNotEmpty);

    if (!hasAnySchedule) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada jadwal kegiatan',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan jadwal kegiatan pertama Anda',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: jadwal.entries.where((entry) => entry.value.isNotEmpty).map((
        entry,
      ) {
        return HariCard(title: entry.key, pelajaran: entry.value);
      }).toList(),
    );
  }
}
