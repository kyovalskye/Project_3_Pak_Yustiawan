// addModal.dart
import 'package:flutter/material.dart';
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
  final TextEditingController _waktuMulaiController = TextEditingController();
  final TextEditingController _waktuSelesaiController = TextEditingController();

  final List<String> _hariList = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  final List<Color> _colorList = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
  ];

  String _selectedHari = 'Senin';
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaKegiatanController.dispose();
    _namaGuruController.dispose();
    _waktuMulaiController.dispose();
    _waktuSelesaiController.dispose();
    super.dispose();
  }

  Future<void> _addSchedule() async {
    // Check if user is logged in
    if (!UserSession.isLoggedIn()) {
      _showSnackBar('Anda harus login terlebih dahulu', Colors.red);
      return;
    }

    if (_namaKegiatanController.text.trim().isEmpty ||
        _waktuMulaiController.text.trim().isEmpty ||
        _waktuSelesaiController.text.trim().isEmpty) {
      _showSnackBar('Harap isi semua field yang wajib', Colors.red);
      return;
    }

    // Validate time format
    if (!_isValidTimeFormat(_waktuMulaiController.text.trim()) ||
        !_isValidTimeFormat(_waktuSelesaiController.text.trim())) {
      _showSnackBar('Format waktu harus HH:MM (contoh: 08:00)', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await SupabaseService.addJadwal(
        namaHari: _selectedHari,
        namaKegiatan: _namaKegiatanController.text.trim(),
        waktuMulai: _waktuMulaiController.text.trim(),
        waktuSelesai: _waktuSelesaiController.text.trim(),
        hexColor: '#${_selectedColor.value.toRadixString(16).substring(2)}',
        namaGuru: _namaGuruController.text.trim().isEmpty
            ? null
            : _namaGuruController.text.trim(),
      );

      if (success) {
        widget.onScheduleAdded?.call();
        Navigator.pop(context);
        _showSnackBar('Jadwal berhasil ditambahkan!', Colors.green);
      } else {
        _showSnackBar('Gagal menambahkan jadwal', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: ${e.toString()}', Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
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
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A4877).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.add_task,
              color: Color(0xFF4A4877),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Tambah Jadwal',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4A4877).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF4A4877).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: 16, color: const Color(0xFF4A4877)),
                  const SizedBox(width: 8),
                  Text(
                    'Ditambahkan oleh: ${UserSession.getCurrentUserName() ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF4A4877),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pilih Hari
            _buildDropdownField(
              label: 'Pilih Hari',
              value: _selectedHari,
              items: _hariList,
              onChanged: (value) {
                setState(() {
                  _selectedHari = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Nama Kegiatan
            _buildTextField(
              label: 'Nama Kegiatan *',
              controller: _namaKegiatanController,
              hintText: 'Masukkan nama kegiatan',
              icon: Icons.book,
            ),
            const SizedBox(height: 16),

            // Nama Guru (Optional)
            _buildTextField(
              label: 'Nama Guru (Opsional)',
              controller: _namaGuruController,
              hintText: 'Masukkan nama guru',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            // Waktu
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Waktu Mulai *',
                    controller: _waktuMulaiController,
                    hintText: '08:00',
                    icon: Icons.access_time,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Waktu Selesai *',
                    controller: _waktuSelesaiController,
                    hintText: '10:00',
                    icon: Icons.access_time_filled,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pilih Warna
            _buildColorPicker(),
            const SizedBox(height: 8),
            Text(
              '* Field wajib diisi',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addSchedule,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A4877),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Tambah'),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
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
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFF9FAFB),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
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
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFF9FAFB),
          ),
          child: TextField(
            controller: controller,
            enabled: !_isLoading,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              border: InputBorder.none,
              prefixIcon: icon != null
                  ? Icon(icon, color: const Color(0xFF9CA3AF), size: 20)
                  : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: icon != null ? 12 : 16,
                vertical: 12,
              ),
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
          children: _colorList.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.black26,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
