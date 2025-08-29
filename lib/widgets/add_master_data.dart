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

  Color _selectedColor = const Color(0xFF2196F3);
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
    super.dispose();
  }

  // Helper method to parse color from different formats (same as original)
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

  // Color picker dialog (from AddModal)
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

  // Build color picker widget (from AddModal)
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

    // Simpan data dengan user_id
    final success = await MasterDataService.addMasterJadwal(
      namaGuru: _namaGuruController.text.trim(),
      namaPelajaran: _namaPelajaranController.text.trim(),
      hexColor:
          '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
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
      _selectedColor = _parseColor(jadwal['hex_color']!);
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
                          final color = _parseColor(jadwal['hex_color']!);
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
                                style: const TextStyle(
                                  color: Colors.black,
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
                    const SizedBox(height: 8),
                    Text(
                      '* Wajib diisi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
            enabled: !_isLoading,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
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
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF9FAFB),
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
