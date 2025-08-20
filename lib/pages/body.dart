// body.dart
import 'package:flutter/material.dart';
import '../widgets/card.dart';
import '../model/pelajaran.dart';
import '../widgets/addButton.dart';
import '../services/supabase_services.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Map<String, List<Pelajaran>> jadwal = {};
  bool isLoading = true;
  String? errorMessage;

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
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await SupabaseService.getAllJadwal();

      // Group data by hari
      final Map<String, List<Pelajaran>> groupedJadwal = {};

      // Initialize all days with empty lists
      for (final hari in hariList) {
        groupedJadwal[hari] = [];
      }

      // Group the data
      for (final item in data) {
        final pelajaran = Pelajaran.fromSupabase(item);
        final hari = pelajaran.namaHari ?? '';

        if (groupedJadwal.containsKey(hari)) {
          groupedJadwal[hari]!.add(pelajaran);
        }
      }

      // Sort each day's schedule by time
      groupedJadwal.forEach((hari, pelajaranList) {
        pelajaranList.sort((a, b) {
          final aTime = a.waktuMulai ?? '00:00';
          final bTime = b.waktuMulai ?? '00:00';
          return aTime.compareTo(bTime);
        });
      });

      setState(() {
        jadwal = groupedJadwal;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat jadwal: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _onScheduleAdded() {
    _loadJadwal(); // Reload data when new schedule is added
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFfaf3f4),
          child: RefreshIndicator(
            onRefresh: _loadJadwal,
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
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4A4877)),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadJadwal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A4877),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

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
        return HariCard(
          title: entry.key,
          pelajaran: entry.value,
          onScheduleChanged:
              _onScheduleAdded, // Add callback for updates/deletes
        );
      }).toList(),
    );
  }
}
