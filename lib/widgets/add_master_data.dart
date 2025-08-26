// add_master_data_services.dart
import 'package:flutter/material.dart';
import '../services/master_data_services.dart';

class AddMasterDataModal extends StatefulWidget {
  const AddMasterDataModal({super.key});

  @override
  State<AddMasterDataModal> createState() => _AddMasterDataModalState();
}

class _AddMasterDataModalState extends State<AddMasterDataModal> {
  final TextEditingController _namaGuruController = TextEditingController();
  final TextEditingController _namaPelajaranController =
      TextEditingController();
  final TextEditingController _waktuMulaiController = TextEditingController();
  final TextEditingController _waktuSelesaiController = TextEditingController();
  Color _selectedColor = const Color(0xFF6366F1);
  String? _errorMessage;
  bool _isLoading = false;
  bool _isLoadingData = true;
  List<Map<String, String>> _masterJadwalList = [];

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  @override
  void dispose() {
    _namaGuruController.dispose();
    _namaPelajaranController.dispose();
    _waktuMulaiController.dispose();
    _waktuSelesaiController.dispose();
    super.dispose();
  }

  Future<void> _loadMasterData() async {
    setState(() => _isLoadingData = true);
    try {
      final jadwal = await MasterDataService.getMasterJadwalForDropdown();
      setState(() {
        _masterJadwalList = jadwal;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      print('Error loading master data: $e');
    }
  }

  bool _validateTimeFormat(String time) {
    final RegExp timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timeRegex.hasMatch(time);
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _handleSave() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Validasi
    if (_namaGuruController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Nama guru harus diisi';
        _isLoading = false;
      });
      return;
    }
    if (_namaPelajaranController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Nama pelajaran harus diisi';
        _isLoading = false;
      });
      return;
    }
    if (!_validateTimeFormat(_waktuMulaiController.text)) {
      setState(() {
        _errorMessage = 'Format waktu mulai tidak valid (HH:mm)';
        _isLoading = false;
      });
      return;
    }
    if (!_validateTimeFormat(_waktuSelesaiController.text)) {
      setState(() {
        _errorMessage = 'Format waktu selesai tidak valid (HH:mm)';
        _isLoading = false;
      });
      return;
    }
    final startTime = _parseTime(_waktuMulaiController.text);
    final endTime = _parseTime(_waktuSelesaiController.text);
    if (endTime.isBefore(startTime)) {
      setState(() {
        _errorMessage = 'Waktu selesai harus setelah waktu mulai';
        _isLoading = false;
      });
      return;
    }

    // Simpan data dengan user_id
    final success = await MasterDataService.addMasterJadwal(
      namaGuru: _namaGuruController.text.trim(),
      namaPelajaran: _namaPelajaranController.text.trim(),
      hexColor: '0x${_selectedColor.value.toRadixString(16).toUpperCase()}',
      waktuMulai: _waktuMulaiController.text.trim(),
      waktuSelesai: _waktuSelesaiController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(
        () => _errorMessage = 'Gagal menyimpan jadwal. Silakan coba lagi.',
      );
    }
  }

  void _selectJadwal(Map<String, String> jadwal) {
    setState(() {
      _namaGuruController.text = jadwal['nama_guru']!;
      _namaPelajaranController.text = jadwal['nama_pelajaran']!;
      _waktuMulaiController.text = jadwal['waktu_mulai']!;
      _waktuSelesaiController.text = jadwal['waktu_selesai']!;
      _selectedColor = Color(
        int.parse(jadwal['hex_color']!.replaceAll('0x', '0xFF')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: _isLoadingData
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF4A4877)),
                    SizedBox(height: 16),
                    Text('Memuat data...'),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[800]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildTextFieldWithLabel(
                      label: 'Nama Guru',
                      controller: _namaGuruController,
                      hint: 'Masukkan nama guru',
                    ),
                    const SizedBox(height: 16),
                    _buildTextFieldWithLabel(
                      label: 'Mata Pelajaran',
                      controller: _namaPelajaranController,
                      hint: 'Masukkan mata pelajaran',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFieldWithLabel(
                            label: 'Waktu Mulai',
                            controller: _waktuMulaiController,
                            hint: '08:00',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextFieldWithLabel(
                            label: 'Waktu Selesai',
                            controller: _waktuSelesaiController,
                            hint: '09:30',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildColorPicker(),
                    const SizedBox(height: 20),
                    if (_masterJadwalList.isNotEmpty) ...[
                      const Text(
                        'Pilih dari Master Data',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _masterJadwalList.map((jadwal) {
                          final color = Color(
                            int.parse(
                              jadwal['hex_color']!.replaceAll('0x', '0xFF'),
                            ),
                          );
                          return GestureDetector(
                            onTap: () => _selectJadwal(jadwal),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: color),
                              ),
                              child: Text(
                                jadwal['nama_pelajaran']!,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                    _buildColorPreview(),
                    const SizedBox(height: 28),
                    _buildActionButtons(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _selectedColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.add_circle_outline,
            color: Color(0xFF4A4877),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Tambah Jadwal',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithLabel({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF9FAFB),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Warna',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              const [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
                Color(0xFFEC4899),
                Color(0xFFEF4444),
                Color(0xFFF97316),
                Color(0xFFEAB308),
                Color(0xFF22C55E),
                Color(0xFF10B981),
                Color(0xFF06B6D4),
                Color(0xFF3B82F6),
                Color(0xFFFF6B6B),
                Color(0xFF4ECDC4),
                Color(0xFF45B7D1),
                Color(0xFF96CEB4),
                Color(0xFFD4A5A5),
                Color(0xFFFFB7C5),
                Color(0xFF9B59B6),
                Color(0xFF3498DB),
                Color(0xFFE74C3C),
                Color(0xFF2ECC71),
              ].map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _selectedColor == color
                          ? Border.all(color: Colors.black, width: 2)
                          : Border.all(color: Colors.black26),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview Jadwal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _selectedColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _namaPelajaranController.text.isEmpty
                    ? 'Mata Pelajaran'
                    : _namaPelajaranController.text,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              if (_namaGuruController.text.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Guru: ${_namaGuruController.text}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
              if (_waktuMulaiController.text.isNotEmpty &&
                  _waktuSelesaiController.text.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '${_waktuMulaiController.text} - ${_waktuSelesaiController.text}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A4877),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Simpan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}
