import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/supabase_services.dart';
import '../services/user_session.dart';

class AddModal extends StatefulWidget {
  final Function? onScheduleAdded;

  const AddModal({super.key, this.onScheduleAdded});

  @override
  State<AddModal> createState() => _AddModalState();
}

class _AddModalState extends State<AddModal> {
  final TextEditingController _namaKegiatanController = TextEditingController();
  final TextEditingController _namaGuruController = TextEditingController();

  final List<String> _hariList = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  final Map<String, List<String>> _timeOptions = {
    'Senin': [
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
    ],
    'Selasa': [
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
    ],
    'Rabu': [
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
    ],
    'Kamis': [
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
    ],
    'Jumat': ['6:30', '7:10', '7:50', '8:30', '9:10', '9:40', '10:20', '11:00'],
    'Sabtu': ['6:30', '7:10', '7:50', '8:30', '9:10', '9:40', '10:20', '11:00'],
    'Minggu': [],
  };

  // Palette warna yang lebih lengkap dan menarik
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

  String _selectedHari = 'Senin';
  String? _selectedWaktuMulai;
  String? _selectedWaktuSelesai;
  Color _selectedColor = const Color(0xFF2196F3);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateTimeOptions();
  }

  void _updateTimeOptions() {
    final availableTimes = _timeOptions[_selectedHari] ?? [];
    if (availableTimes.isEmpty) {
      _selectedWaktuMulai = null;
      _selectedWaktuSelesai = null;
    } else {
      if (_selectedWaktuMulai != null &&
          !availableTimes.contains(_selectedWaktuMulai)) {
        _selectedWaktuMulai = null;
      }
      if (_selectedWaktuSelesai != null &&
          !availableTimes.contains(_selectedWaktuSelesai)) {
        _selectedWaktuSelesai = null;
      }
    }
  }

  List<String> _getAvailableEndTimes() {
    final availableTimes = _timeOptions[_selectedHari] ?? [];
    if (_selectedWaktuMulai == null) return availableTimes;
    return availableTimes
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

  Future<bool> _checkScheduleConflict() async {
    if (_selectedWaktuMulai == null || _selectedWaktuSelesai == null) {
      return false;
    }

    try {
      // Ambil semua jadwal untuk hari yang dipilih
      final schedules = await SupabaseService.getJadwalByHari(_selectedHari);

      // Konversi waktu mulai dan selesai ke menit untuk perbandingan
      final newStartTime = _timeToMinutes(_selectedWaktuMulai!);
      final newEndTime = _timeToMinutes(_selectedWaktuSelesai!);

      // Periksa setiap jadwal yang ada
      for (var schedule in schedules) {
        final existingStartTime = _timeToMinutes(schedule['waktu_mulai']);
        final existingEndTime = _timeToMinutes(schedule['waktu_selesai']);

        // Cek apakah ada tumpang tindih
        // Jadwal baru bertabrakan jika:
        // - Mulai sebelum jadwal yang ada selesai DAN
        // - Selesai setelah jadwal yang ada mulai
        if (newStartTime < existingEndTime && newEndTime > existingStartTime) {
          return true; // Ada konflik
        }
      }
      return false; // Tidak ada konflik
    } catch (e) {
      _showSnackBar('Error memeriksa konflik: ${e.toString()}', Colors.red);
      return true; // Asumsikan ada konflik jika terjadi error
    }
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Future<void> _addSchedule() async {
    if (!UserSession.isLoggedIn()) {
      _showSnackBar('Login dulu ya!', Colors.red);
      return;
    }

    if (_namaKegiatanController.text.trim().isEmpty ||
        _selectedWaktuMulai == null ||
        _selectedWaktuSelesai == null) {
      _showSnackBar('Isi nama kegiatan dan waktu dulu', Colors.red);
      return;
    }

    if (!_isValidTimeSequence(_selectedWaktuMulai!, _selectedWaktuSelesai!)) {
      _showSnackBar('Waktu selesai harus setelah mulai', Colors.red);
      return;
    }

    // Cek konflik jadwal
    final hasConflict = await _checkScheduleConflict();
    if (hasConflict) {
      _showSnackBar('Jadwal bertabrakan dengan jadwal lain!', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await SupabaseService.addJadwal(
        namaHari: _selectedHari,
        namaKegiatan: _namaKegiatanController.text.trim(),
        waktuMulai: _selectedWaktuMulai!,
        waktuSelesai: _selectedWaktuSelesai!,
        hexColor:
            '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
        namaGuru: _namaGuruController.text.trim().isNotEmpty
            ? _namaGuruController.text.trim()
            : null,
      );

      if (success) {
        widget.onScheduleAdded?.call();
        Navigator.pop(context);
        _showSnackBar('Jadwal ditambahkan!', Colors.green);
      } else {
        _showSnackBar('Gagal tambah jadwal', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }

    setState(() => _isLoading = false);
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _namaKegiatanController.dispose();
    _namaGuruController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A4877),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_task,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tambah Jadwal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDropdown(
                            'Pilih Hari',
                            _selectedHari,
                            _hariList,
                            (v) {
                              setState(() {
                                _selectedHari = v!;
                                _updateTimeOptions();
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Nama Kegiatan *',
                            _namaKegiatanController,
                            'Contoh: Matematika',
                            Icons.book,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Nama Guru (Opsional)',
                            _namaGuruController,
                            'Contoh: Pak Budi',
                            Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          if (_timeOptions[_selectedHari]?.isNotEmpty == true)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimeDropdown(
                                    'Waktu Mulai *',
                                    _selectedWaktuMulai,
                                    _timeOptions[_selectedHari]!,
                                    (v) {
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
                                    Icons.access_time,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTimeDropdown(
                                    'Waktu Selesai *',
                                    _selectedWaktuSelesai,
                                    _getAvailableEndTimes(),
                                    (v) => setState(
                                      () => _selectedWaktuSelesai = v,
                                    ),
                                    Icons.access_time_filled,
                                  ),
                                ),
                              ],
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Tidak ada waktu untuk hari $_selectedHari',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          const Text(
                            'Pilih Warna *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 12),
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
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ||
                                    _timeOptions[_selectedHari]?.isEmpty == true
                                ? null
                                : _addSchedule,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A4877),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Tambah Jadwal'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
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
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
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

  Widget _buildTimeDropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
    IconData icon,
  ) {
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
}
