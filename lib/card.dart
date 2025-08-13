import 'package:flutter/material.dart';
import 'model/pelajaran.dart';

class HariCard extends StatelessWidget {
  final String title;
  final List<Pelajaran> pelajaran;
  final Function? onScheduleChanged;

  const HariCard({
    super.key,
    required this.title,
    required this.pelajaran,
    this.onScheduleChanged,
  });

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
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
