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
  String? _selectedWaktuMulai;
  String? _selectedWaktuSelesai;
  Color _selectedColor = const Color(0xFF2196F3);
  String? _errorMessage;
  bool _isLoading = false;
  bool _isLoadingData = true;
  List<Map<String, String>> _masterJadwalList = [];

  // Daftar waktu yang tersedia
  final List<String> _timeOptions = [
    '6:30',
    '7:10',
    '7:50',
    '8:30',
    '9:10',
    '9:40',
    '10:20',
    '11:00',
    '11:40',
    '12:20',
    '13:00',
    '13:40',
    '14:20',
  ];

  // Palette warna yang sama seperti di AddModal.dart
  final List<List<Color>> _colorPalettes = [
    // Palette Merah
    [
      const Color(0xFFFFEBEE),
      const Color(0xFFFFCDD2),
      const Color(0xFFEF9A9A),
      const Color(0xFFE57373),
      const Color(0xFFEF5350),
      const Color(0xFFF44336),
      const Color(0xFFE53935),
      const Color(0xFFD32F2F),
      const Color(0xFFC62828),
      const Color(0xFFB71C1C),
    ],
    // Palette Pink
    [
      const Color(0xFFFCE4EC),
      const Color(0xFFF8BBD9),
      const Color(0xFFF48FB1),
      const Color(0xFFF06292),
      const Color(0xFFEC407A),
      const Color(0xFFE91E63),
      const Color(0xFFD81B60),
      const Color(0xFFC2185B),
      const Color(0xFFAD1457),
      const Color(0xFF880E4F),
    ],
    // Palette Ungu
    [
      const Color(0xFFF3E5F5),
      const Color(0xFFE1BEE7),
      const Color(0xFFCE93D8),
      const Color(0xFFBA68C8),
      const Color(0xFFAB47BC),
      const Color(0xFF9C27B0),
      const Color(0xFF8E24AA),
      const Color(0xFF7B1FA2),
      const Color(0xFF6A1B9A),
      const Color(0xFF4A148C),
    ],
    // Palette Biru
    [
      const Color(0xFFE3F2FD),
      const Color(0xFFBBDEFB),
      const Color(0xFF90CAF9),
      const Color(0xFF64B5F6),
      const Color(0xFF42A5F5),
      const Color(0xFF2196F3),
      const Color(0xFF1E88E5),
      const Color(0xFF1976D2),
      const Color(0xFF1565C0),
      const Color(0xFF0D47A1),
    ],
    // Palette Hijau
    [
      const Color(0xFFE8F5E8),
      const Color(0xFFC8E6C9),
      const Color(0xFFA5D6A7),
      const Color(0xFF81C784),
      const Color(0xFF66BB6A),
      const Color(0xFF4CAF50),
      const Color(0xFF43A047),
      const Color(0xFF388E3C),
      const Color(0xFF2E7D32),
      const Color(0xFF1B5E20),
    ],
    // Palette Kuning/Orange
    [
      const Color(0xFFFFF8E1),
      const Color(0xFFFFECB3),
      const Color(0xFFFFE082),
      const Color(0xFFFFD54F),
      const Color(0xFFFFCA28),
      const Color(0xFFFFC107),
      const Color(0xFFFFB300),
      const Color(0xFFFFA000),
      const Color(0xFFFF8F00),
      const Color(0xFFFF6F00),
    ],
    // Palette Abu-abu
    [
      const Color(0xFFFAFAFA),
      const Color(0xFFF5F5F5),
      const Color(0xFFEEEEEE),
      const Color(0xFFE0E0E0),
      const Color(0xFFBDBDBD),
      const Color(0xFF9E9E9E),
      const Color(0xFF757575),
      const Color(0xFF616161),
      const Color(0xFF424242),
      const Color(0xFF212121),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  @override
  void dispose() {
    _namaGuruController.dispose();
    _namaPelajaranController.dispose();
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

  List<String> _getAvailableEndTimes() {
    if (_selectedWaktuMulai == null) return _timeOptions;
    return _timeOptions
        .where((time) => _isValidTimeSequence(_selectedWaktuMulai!, time))
        .toList();
  }

  bool _isValidTimeSequence(String startTime, String endTime) {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    return endMinutes > startMinutes;
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color tempSelectedColor = _selectedColor;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Pilih Warna',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 60,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: tempSelectedColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Preview Warna',
                          style: TextStyle(
                            color: _getTextColor(tempSelectedColor),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      height: 280,
                      child: ListView.builder(
                        itemCount: _colorPalettes.length,
                        itemBuilder: (context, paletteIndex) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _colorPalettes[paletteIndex]
                                  .map(
                                    (color) => GestureDetector(
                                      onTap: () {
                                        setDialogState(() {
                                          tempSelectedColor = color;
                                        });
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: tempSelectedColor == color
                                                ? Colors.black87
                                                : Colors.grey.withOpacity(0.3),
                                            width: tempSelectedColor == color
                                                ? 2.5
                                                : 0.5,
                                          ),
                                          boxShadow: tempSelectedColor == color
                                              ? [
                                                  BoxShadow(
                                                    color: color.withOpacity(
                                                      0.4,
                                                    ),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: tempSelectedColor == color
                                            ? Icon(
                                                Icons.check,
                                                color: _getTextColor(color),
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedColor = tempSelectedColor;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4877),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Pilih'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getTextColor(Color backgroundColor) {
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black87 : Colors.white;
  }

  Future<void> _handleSave() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

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
    if (_selectedWaktuMulai == null) {
      setState(() {
        _errorMessage = 'Waktu mulai harus dipilih';
        _isLoading = false;
      });
      return;
    }
    if (_selectedWaktuSelesai == null) {
      setState(() {
        _errorMessage = 'Waktu selesai harus dipilih';
        _isLoading = false;
      });
      return;
    }
    if (!_isValidTimeSequence(_selectedWaktuMulai!, _selectedWaktuSelesai!)) {
      setState(() {
        _errorMessage = 'Waktu selesai harus setelah waktu mulai';
        _isLoading = false;
      });
      return;
    }

    final success = await MasterDataService.addMasterJadwal(
      namaGuru: _namaGuruController.text.trim(),
      namaPelajaran: _namaPelajaranController.text.trim(),
      hexColor:
          '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
      waktuMulai: _selectedWaktuMulai!,
      waktuSelesai: _selectedWaktuSelesai!,
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
      _selectedWaktuMulai = jadwal['waktu_mulai']!;
      _selectedWaktuSelesai = jadwal['waktu_selesai']!;
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
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFieldWithLabel(
                      label: 'Mata Pelajaran',
                      controller: _namaPelajaranController,
                      hint: 'Masukkan mata pelajaran',
                      icon: Icons.book,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeDropdown(
                            label: 'Waktu Mulai *',
                            value: _selectedWaktuMulai,
                            items: _timeOptions,
                            onChanged: (v) {
                              setState(() {
                                _selectedWaktuMulai = v;
                                if (_selectedWaktuSelesai != null &&
                                    !_isValidTimeSequence(
                                      v!,
                                      _selectedWaktuSelesai!,
                                    )) {
                                  _selectedWaktuSelesai = null;
                                }
                              });
                            },
                            icon: Icons.access_time,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimeDropdown(
                            label: 'Waktu Selesai *',
                            value: _selectedWaktuSelesai,
                            items: _getAvailableEndTimes(),
                            onChanged: (v) =>
                                setState(() => _selectedWaktuSelesai = v),
                            icon: Icons.access_time_filled,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildColorSelection(),
                    const SizedBox(height: 8),
                    Text(
                      '* Wajib diisi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
    required IconData icon,
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
        TextField(
          controller: controller,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTimeDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
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
            border: Border.all(color: const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(
              'Pilih',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: _isLoading ? null : onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelection() {
    return GestureDetector(
      onTap: _showColorPickerDialog,
      child: Container(
        width: double.infinity,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.4),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Tap untuk memilih warna',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ],
        ),
      ),
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
                  color: _getTextColor(_selectedColor),
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
                    color: _getTextColor(_selectedColor).withOpacity(0.9),
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
              if (_selectedWaktuMulai != null &&
                  _selectedWaktuSelesai != null) ...[
                const SizedBox(height: 4),
                Text(
                  '$_selectedWaktuMulai - $_selectedWaktuSelesai',
                  style: TextStyle(
                    color: _getTextColor(_selectedColor).withOpacity(0.9),
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
