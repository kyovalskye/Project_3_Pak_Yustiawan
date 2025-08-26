//card.dart
import 'package:flutter/material.dart';
import '../model/pelajaran.dart';
import '../services/supabase_services.dart';

class HariCard extends StatelessWidget {
  final String title;
  final List<Pelajaran> pelajaran;
  final Function? onScheduleChanged;

  HariCard({
    super.key,
    required this.title,
    required this.pelajaran,
    this.onScheduleChanged,
  });

  final List<String> _hariList = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  Future<void> _deleteSchedule(
    BuildContext context,
    Pelajaran pelajaran,
  ) async {
    if (pelajaran.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Jadwal',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus jadwal "${pelajaran.nama}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await SupabaseService.deleteJadwal(pelajaran.id!);
      if (success) {
        onScheduleChanged?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus jadwal!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditDialog(BuildContext context, Pelajaran item) {
    final namaController = TextEditingController(text: item.nama);
    final namaGuruController = TextEditingController(
      text: item.namaGuru ?? '',
    ); // Added teacher name controller
    final mulaiController = TextEditingController(text: item.waktuMulai);
    final selesaiController = TextEditingController(text: item.waktuSelesai);
    String selectedHari = item.namaHari ?? _hariList.first;
    Color selectedColor = item.warna;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Edit Jadwal'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pilih Hari
                  DropdownButtonFormField<String>(
                    value: selectedHari,
                    items: _hariList.map((hari) {
                      return DropdownMenuItem(value: hari, child: Text(hari));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedHari = value);
                    },
                    decoration: const InputDecoration(labelText: 'Pilih Hari'),
                  ),
                  const SizedBox(height: 8),

                  // Nama kegiatan
                  TextField(
                    controller: namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Kegiatan',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Nama guru
                  TextField(
                    controller: namaGuruController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Guru (Opsional)',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Jam mulai
                  TextField(
                    controller: mulaiController,
                    decoration: const InputDecoration(
                      labelText: 'Waktu Mulai (HH:MM)',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Jam selesai
                  TextField(
                    controller: selesaiController,
                    decoration: const InputDecoration(
                      labelText: 'Waktu Selesai (HH:MM)',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Pilih warna
                  Row(
                    children: [
                      const Text('Pilih Warna:'),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDialog<Color>(
                            context: context,
                            builder: (context) {
                              final colors = [
                                Colors.red,
                                Colors.blue,
                                Colors.green,
                                Colors.orange,
                                Colors.purple,
                                Colors.pink,
                                Colors.teal,
                              ];
                              return AlertDialog(
                                title: const Text('Pilih Warna'),
                                content: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: colors.map((c) {
                                    return GestureDetector(
                                      onTap: () => Navigator.pop(context, c),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: c,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.black26,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() => selectedColor = picked);
                          }
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: selectedColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await SupabaseService.updateJadwal(
                    id: item.id!,
                    namaHari: selectedHari,
                    namaKegiatan: namaController.text,
                    waktuMulai: mulaiController.text,
                    waktuSelesai: selesaiController.text,
                    hexColor:
                        '#${selectedColor.value.toRadixString(16).substring(2)}',
                    namaGuru: namaGuruController.text.trim().isEmpty
                        ? null
                        : namaGuruController.text.trim(), // Pass teacher name
                  );

                  if (success) {
                    onScheduleChanged?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Jadwal berhasil diupdate!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal mengupdate jadwal!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF4A4877),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${pelajaran.length} kegiatan',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Body
          if (pelajaran.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tidak ada kegiatan',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pelajaran.length,
              itemBuilder: (context, index) {
                final item = pelajaran[index];
                final isLast = index == pelajaran.length - 1;

                return Container(
                  margin: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: index == 0 ? 16 : 0,
                    bottom: isLast ? 20 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: item.warna.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.warna.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.warna,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    title: Text(
                      item.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          // Teacher name section - positioned on the left
                          if (item.namaGuru != null &&
                              item.namaGuru!.isNotEmpty) ...[
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.namaGuru!,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 1,
                              height: 12,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 12),
                          ],
                          // Time section - positioned on the right of teacher name
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.jam,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Edit',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(context, item);
                        } else if (value == 'delete') {
                          _deleteSchedule(context, item);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
