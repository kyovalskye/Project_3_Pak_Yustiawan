import 'package:flutter/material.dart';
import '../services/master_data_services.dart';
import '../widgets/add_master_data.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Master Data State
  List<Map<String, dynamic>> masterJadwalList = [];
  bool isLoadingMasterData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadMasterData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMasterData() async {
    setState(() => isLoadingMasterData = true);
    try {
      final jadwal = await MasterDataService.getAllMasterJadwal();
      setState(() {
        masterJadwalList = jadwal;
        isLoadingMasterData = false;
      });
    } catch (e) {
      setState(() => isLoadingMasterData = false);
      print('Error loading master data: $e');
    }
  }

  Future<void> _deleteJadwal(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await MasterDataService.deleteMasterJadwal(id);
      if (success) {
        _loadMasterData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfaf3f4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A4877),
        foregroundColor: Colors.white,
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Master Data')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMasterDataTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final success = await showDialog<bool>(
            context: context,
            builder: (context) => const AddMasterDataModal(),
          );
          if (success == true) {
            _loadMasterData();
          }
        },
        backgroundColor: const Color(0xFF4A4877),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMasterDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(icon: Icons.schedule, title: 'Daftar Jadwal'),
          const SizedBox(height: 16),
          if (isLoadingMasterData)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A4877)),
            )
          else if (masterJadwalList.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada jadwal',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            _buildJadwalList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4A4877).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF4A4877), size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildJadwalList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: masterJadwalList.length,
      itemBuilder: (context, index) {
        final jadwal = masterJadwalList[index];
        final color = Color(
          int.parse(jadwal['hex_color'].replaceAll('0x', '0xFF')),
        );
        return Container(
          margin: EdgeInsets.only(
            bottom: index == masterJadwalList.length - 1 ? 0 : 12,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
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
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: Text(
              jadwal['nama_pelajaran'],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF1F2937),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      jadwal['nama_guru'],
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${jadwal['waktu_mulai']} - ${jadwal['waktu_selesai']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteJadwal(jadwal['id']),
            ),
          ),
        );
      },
    );
  }
}
