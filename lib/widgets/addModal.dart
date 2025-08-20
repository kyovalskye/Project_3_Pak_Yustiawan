import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../services/supabase_services.dart';
import '../services/master_data_services.dart';

class AddModal extends StatefulWidget {
  final Function? onScheduleAdded;

  const AddModal({super.key, this.onScheduleAdded});

  @override
  State<AddModal> createState() => _AddModalState();
}

class _AddModalState extends State<AddModal> {
  String? selectedHari;
  final TextEditingController _namaGuruController = TextEditingController();
  final TextEditingController _namaPelajaranController =
      TextEditingController();
  String? _selectedJamMulai;
  String? _selectedJamBerakhir;
  Color _selectedColor = const Color(0xFF6366F1);
  String? _errorMessage;
  bool _isLoading = false;
  bool _isLoadingData = true;
  List<Map<String, String>> _masterJadwalList = [];
  Map<String, List<String>> _timeSlots = {};

  final List<String> _hariList = [
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
    _timeSlots = {
      'Senin': _generateTimeSlots('07:30', '13:40'),
      'Selasa': _generateTimeSlots('06:30', '14:20'),
      'Rabu': _generateTimeSlots('06:30', '14:20'),
      'Kamis': _generateTimeSlots('06:30', '14:20'),
      'Jumat': _generateTimeSlots('06:30', '11:00'),
      'Sabtu': _generateTimeSlots('06:30', '11:00'),
    };
    _loadMasterData();
  }

  List<String> _generateTimeSlots(String startTime, String endTime) {
    List<String> slots = [];
    TimeOfDay start = _parseTime(startTime);
    TimeOfDay end = _parseTime(endTime);
    DateTime startDateTime = DateTime(2025, 8, 20, start.hour, start.minute);
    DateTime endDateTime = DateTime(2025, 8, 20, end.hour, end.minute);

    while (startDateTime.isBefore(endDateTime) ||
        startDateTime.isAtSameMomentAs(endDateTime)) {
      slots.add(
        '${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}',
      );
      startDateTime = startDateTime.add(const Duration(minutes: 40));
    }
    return slots;
  }

  Future<void> _loadMasterData() async {
    setState(() => _isLoadingData = true);
    try {
      final jadwal = await MasterDataService.getMasterJadwalForDropdown();
      setState(() {
        _masterJadwalList = jadwal ?? [];
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

    if (selectedHari == null) {
      setState(() {
        _errorMessage = 'Pilih hari terlebih dahulu';
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
    if (_selectedJamMulai == null) {
      setState(() {
        _errorMessage = 'Pilih jam mulai';
        _isLoading = false;
      });
      return;
    }
    if (_selectedJamBerakhir == null) {
      setState(() {
        _errorMessage = 'Pilih jam berakhir';
        _isLoading = false;
      });
      return;
    }
    final startTime = _parseTime(_selectedJamMulai!);
    final endTime = _parseTime(_selectedJamBerakhir!);
    if (endTime.isBefore(startTime)) {
      setState(() {
        _errorMessage = 'Jam berakhir harus setelah jam mulai';
        _isLoading = false;
      });
      return;
    }

    final hasConflict = await SupabaseService.checkScheduleConflict(
      namaHari: selectedHari!,
      waktuMulai: _selectedJamMulai!,
      waktuSelesai: _selectedJamBerakhir!,
    );
    if (hasConflict) {
      setState(() {
        _errorMessage = 'Sudah ada jadwal di hari dan waktu yang sama';
        _isLoading = false;
      });
      return;
    }

    final success = await SupabaseService.addJadwal(
      namaHari: selectedHari!,
      namaKegiatan: _namaPelajaranController.text.trim(),
      waktuMulai: _selectedJamMulai!,
      waktuSelesai: _selectedJamBerakhir!,
      hexColor: '0x${_selectedColor.value.toRadixString(16).toUpperCase()}',
      namaGuru: _namaGuruController.text.trim().isEmpty
          ? null
          : _namaGuruController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      widget.onScheduleAdded?.call();
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
      selectedHari =
          jadwal['nama_hari'] ??
          _hariList[0]; // Default ke hari pertama jika null
      _namaGuruController.text = jadwal['nama_guru'] ?? '';
      _namaPelajaranController.text = jadwal['nama_pelajaran'] ?? '';
      _selectedJamMulai = jadwal['waktu_mulai'];
      _selectedJamBerakhir = jadwal['waktu_selesai'];
      _selectedColor = Color(
        int.tryParse(
              jadwal['hex_color']?.replaceAll('0x', '0xFF') ?? '0xFF6366F1',
            ) ??
            0xFF6366F1,
      );

      // Pastikan waktu yang dipilih valid dalam _timeSlots
      if (selectedHari != null &&
          !_timeSlots[selectedHari!]!.contains(_selectedJamMulai)) {
        _selectedJamMulai = _timeSlots[selectedHari!]!.isNotEmpty
            ? _timeSlots[selectedHari!]!.first
            : null;
      }
      if (selectedHari != null &&
          !_timeSlots[selectedHari!]!.contains(_selectedJamBerakhir)) {
        _selectedJamBerakhir = _timeSlots[selectedHari!]!.isNotEmpty
            ? _timeSlots[selectedHari!]!.last
            : null;
      }
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
                    _buildHariDropdown(),
                    const SizedBox(height: 16),
                    _buildTextFieldWithLabel(
                      label: 'Nama Guru (Opsional)',
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
                          child: _buildTimeDropdown(
                            label: 'Jam Mulai',
                            value: _selectedJamMulai,
                            items: selectedHari != null
                                ? _timeSlots[selectedHari!]!
                                : [],
                            onChanged: (value) =>
                                setState(() => _selectedJamMulai = value),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTimeDropdown(
                            label: 'Jam Berakhir',
                            value: _selectedJamBerakhir,
                            items: selectedHari != null
                                ? _timeSlots[selectedHari!]!
                                : [],
                            onChanged: (value) =>
                                setState(() => _selectedJamBerakhir = value),
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
          'Tambah Jadwal Kegiatan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildHariDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hari',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF9FAFB),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedHari,
              hint: const Text(
                'Pilih hari',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
              isExpanded: true,
              items: _hariList.map((hari) {
                return DropdownMenuItem(
                  value: hari,
                  child: Text(
                    hari,
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                selectedHari = value;
                _selectedJamMulai = null;
                _selectedJamBerakhir = null;
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF9FAFB),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: const Text(
                'Pilih jam',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
              isExpanded: true,
              items: items.isNotEmpty
                  ? items.map((jam) {
                      return DropdownMenuItem(
                        value: jam,
                        child: Text(
                          jam,
                          style: const TextStyle(
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList()
                  : [const DropdownMenuItem(child: Text('Tidak ada opsi'))],
              onChanged: onChanged,
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
        GestureDetector(
          onTap: () async {
            final picked = await showDialog<Color>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Pilih Warna'),
                content: SingleChildScrollView(
                  child: BlockPicker(
                    pickerColor: _selectedColor,
                    onColorChanged: (color) =>
                        setState(() => _selectedColor = color),
                    availableColors: const [
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
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ],
              ),
            );
            if (picked != null) {
              setState(() => _selectedColor = picked);
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _selectedColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26),
            ),
          ),
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
              if (_selectedJamMulai != null &&
                  _selectedJamBerakhir != null) ...[
                const SizedBox(height: 4),
                Text(
                  '$_selectedJamMulai - $_selectedJamBerakhir',
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
}
