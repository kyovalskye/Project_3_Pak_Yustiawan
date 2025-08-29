import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/supabase_services.dart';
import '../services/user_session.dart';
import '../services/master_data_services.dart'; // Tambahkan impor untuk MasterDataService

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

  String _selectedHari = 'Senin';
  String? _selectedWaktuMulai;
  String? _selectedWaktuSelesai;
  Color _selectedColor = const Color(0xFF2196F3);
  bool _isLoading = false;
  bool _isLoadingMasterData = false; // State untuk loading master data
  List<Map<String, String>> _masterJadwalList =
      []; // State untuk menyimpan master data

  @override
  void initState() {
    super.initState();
    _updateTimeOptions();
    _loadMasterData(); // Muat data master saat inisialisasi
  }

  // Fungsi untuk memuat data master
  Future<void> _loadMasterData() async {
    setState(() => _isLoadingMasterData = true);
    try {
      final jadwal = await MasterDataService.getMasterJadwalForDropdown();
      setState(() {
        _masterJadwalList = jadwal;
        _isLoadingMasterData = false;
      });
    } catch (e) {
      setState(() => _isLoadingMasterData = false);
      _showSnackBar('Gagal memuat data master: ${e.toString()}', Colors.red);
    }
  }

  // Fungsi untuk parsing warna
  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.trim();
      if (hexColor.startsWith('#')) {
        hexColor = hexColor.substring(1);
        if (hexColor.length == 6) {
          hexColor = 'FF$hexColor';
        }
        return Color(int.parse(hexColor, radix: 16));
      }
      if (hexColor.startsWith('0x')) {
        return Color(int.parse(hexColor));
      }
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      print('Error parsing color $hexColor: $e');
      return const Color(0xFF6366F1);
    }
  }

  // Fungsi untuk memilih data master
  void _selectMasterJadwal(Map<String, String> jadwal) {
    setState(() {
      _namaKegiatanController.text = jadwal['nama_pelajaran']!;
      _namaGuruController.text = jadwal['nama_guru']!;
      _selectedColor = _parseColor(jadwal['hex_color']!);
    });
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
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preview Container
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
                    // Color Picker Widget
                    _buildColorPicker(tempSelectedColor, (Color color) {
                      setDialogState(() {
                        tempSelectedColor = color;
                      });
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.black87),
                  ),
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

  Widget _buildColorPicker(Color currentColor, Function(Color) onColorChanged) {
    HSVColor hsvColor = HSVColor.fromColor(currentColor);

    return SizedBox(
      width: 300,
      height: 280,
      child: Column(
        children: [
          // Hue Slider
          Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Text(
                  'Hue:',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 20,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: hsvColor.hue,
                      min: 0,
                      max: 360,
                      onChanged: (value) {
                        hsvColor = hsvColor.withHue(value);
                        onColorChanged(hsvColor.toColor());
                      },
                      activeColor: HSVColor.fromAHSV(
                        1.0,
                        hsvColor.hue,
                        1.0,
                        1.0,
                      ).toColor(),
                      inactiveColor: Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Saturation Slider
          Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Text(
                  'Saturation:',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 20,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            HSVColor.fromAHSV(
                              1.0,
                              hsvColor.hue,
                              0.0,
                              hsvColor.value,
                            ).toColor(),
                            HSVColor.fromAHSV(
                              1.0,
                              hsvColor.hue,
                              1.0,
                              hsvColor.value,
                            ).toColor(),
                          ],
                        ),
                      ),
                      child: Slider(
                        value: hsvColor.saturation,
                        min: 0,
                        max: 1,
                        onChanged: (value) {
                          hsvColor = hsvColor.withSaturation(value);
                          onColorChanged(hsvColor.toColor());
                        },
                        activeColor: Colors.transparent,
                        inactiveColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Value/Brightness Slider
          Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Text(
                  'Brightness:',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 20,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            HSVColor.fromAHSV(
                              1.0,
                              hsvColor.hue,
                              hsvColor.saturation,
                              0.0,
                            ).toColor(),
                            HSVColor.fromAHSV(
                              1.0,
                              hsvColor.hue,
                              hsvColor.saturation,
                              1.0,
                            ).toColor(),
                          ],
                        ),
                      ),
                      child: Slider(
                        value: hsvColor.value,
                        min: 0,
                        max: 1,
                        onChanged: (value) {
                          hsvColor = hsvColor.withValue(value);
                          onColorChanged(hsvColor.toColor());
                        },
                        activeColor: Colors.transparent,
                        inactiveColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quick Color Presets
          const Text(
            'Warna Cepat:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                      Colors.red,
                      Colors.pink,
                      Colors.purple,
                      Colors.blue,
                      Colors.cyan,
                      Colors.green,
                      Colors.yellow,
                      Colors.orange,
                      Colors.brown,
                      Colors.grey,
                    ]
                    .map(
                      (color) => GestureDetector(
                        onTap: () => onColorChanged(color),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: currentColor == color
                                  ? Colors.black87
                                  : Colors.grey.withOpacity(0.3),
                              width: currentColor == color ? 2.5 : 1,
                            ),
                          ),
                          child: currentColor == color
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
        ],
      ),
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
      final schedules = await SupabaseService.getJadwalByHari(_selectedHari);
      final newStartTime = _timeToMinutes(_selectedWaktuMulai!);
      final newEndTime = _timeToMinutes(_selectedWaktuSelesai!);

      for (var schedule in schedules) {
        final existingStartTime = _timeToMinutes(schedule['waktu_mulai']);
        final existingEndTime = _timeToMinutes(schedule['waktu_selesai']);
        if (newStartTime < existingEndTime && newEndTime > existingStartTime) {
          return true;
        }
      }
      return false;
    } catch (e) {
      _showSnackBar('Error memeriksa konflik: ${e.toString()}', Colors.red);
      return true;
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
                  // Header
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
                  // Konten utama
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
                          // Bagian untuk memilih master data
                          if (_isLoadingMasterData)
                            const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: Color(0xFF4A4877),
                                ),
                                SizedBox(height: 8),
                                Text('Memuat data master...'),
                              ],
                            )
                          else if (_masterJadwalList.isNotEmpty) ...[
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
                                final color = _parseColor(jadwal['hex_color']!);
                                return GestureDetector(
                                  onTap: () => _selectMasterJadwal(jadwal),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: color),
                                    ),
                                    child: Text(
                                      jadwal['nama_pelajaran']!,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
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
                  // Footer
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
                            child: const Text(
                              'Batal',
                              style: TextStyle(color: Colors.black87),
                            ),
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
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            dropdownColor: Colors.white,
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
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
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
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                )
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
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            dropdownColor: Colors.white,
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
              Icons.palette_outlined,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
