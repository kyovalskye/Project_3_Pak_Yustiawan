// profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_project3/services/profile_services.dart';
import 'package:flutter_project3/services/user_session.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _namaProfileController = TextEditingController(
    text: 'Nama Pengguna',
  );
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _profilePictureUrl;
  File? _selectedImage;
  Uint8List? _webImage;
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _namaProfileController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load from SharedPreferences first
      await UserSession.loadUserFromPrefs();

      final user = await ProfileService.getUserProfile();
      if (user != null) {
        setState(() {
          _namaProfileController.text = user['nama'] ?? 'Nama Pengguna';
          _profilePictureUrl = user['profile_picture'];
        });
        await UserSession.setCurrentUser(user);
        print('Profile loaded - Picture URL: ${user['profile_picture']}');
      } else {
        final currentUser = UserSession.getCurrentUser();
        if (currentUser != null) {
          setState(() {
            _namaProfileController.text =
                currentUser['nama'] ?? 'Nama Pengguna';
            _profilePictureUrl = currentUser['profile_picture'];
          });
        } else {
          setState(() {
            _namaProfileController.text = 'Nama Pengguna';
            _profilePictureUrl = null;
          });
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      final currentUser = UserSession.getCurrentUser();
      if (currentUser != null) {
        setState(() {
          _namaProfileController.text = currentUser['nama'] ?? 'Nama Pengguna';
          _profilePictureUrl = currentUser['profile_picture'];
        });
      } else {
        setState(() {
          _namaProfileController.text = 'Nama Pengguna';
          _profilePictureUrl = null;
        });
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();

      // Show options for image source
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print('Image picked: ${pickedFile.path}');

        if (kIsWeb) {
          final webImage = await pickedFile.readAsBytes();
          setState(() {
            _webImage = webImage;
            _selectedImage = null;
          });
          print('Web image loaded: ${webImage.length} bytes');
        } else {
          // Verify file exists for mobile
          final file = File(pickedFile.path);
          final exists = await file.exists();
          print('Mobile file exists: $exists, path: ${pickedFile.path}');

          if (exists) {
            // Test reading the file
            try {
              final bytes = await file.readAsBytes();
              print('Mobile file readable: ${bytes.length} bytes');

              setState(() {
                _selectedImage = file;
                _webImage = null;
              });
            } catch (readError) {
              print('Error reading selected file: $readError');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error reading selected image file'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
          } else {
            print('Selected file does not exist');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selected image file not found'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_namaProfileController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? profilePictureUrl = _profilePictureUrl;

      // Upload new image if selected
      if (kIsWeb && _webImage != null) {
        print('Starting web image upload...');
        profilePictureUrl = await ProfileService.uploadProfilePictureWeb(
          _webImage!,
        );
        if (profilePictureUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengunggah foto profil'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        print('Web upload success - URL: $profilePictureUrl');
      } else if (!kIsWeb && _selectedImage != null) {
        print('Starting mobile image upload...');
        print('Selected file path: ${_selectedImage!.path}');

        // Double check file exists before upload
        if (!await _selectedImage!.exists()) {
          print('Selected image file no longer exists');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File gambar tidak ditemukan'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        profilePictureUrl = await ProfileService.uploadProfilePicture(
          _selectedImage!.path,
        );
        if (profilePictureUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Gagal mengunggah foto profil. Periksa koneksi internet dan coba lagi.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        print('Mobile upload success - URL: $profilePictureUrl');
      }

      // Update profile
      final success = await ProfileService.updateUserProfile(
        nama: _namaProfileController.text.trim(),
        profilePictureUrl: profilePictureUrl,
      );

      if (success) {
        // Refresh user session
        final updatedUser = await ProfileService.getUserProfile();
        if (updatedUser != null) {
          await UserSession.setCurrentUser(updatedUser);
          print(
            'Session updated - Picture URL: ${updatedUser['profile_picture']}',
          );
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _profilePictureUrl = profilePictureUrl;
          _selectedImage = null;
          _webImage = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kolom kata sandi harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi baru dan konfirmasi tidak cocok'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi baru harus minimal 6 karakter'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ProfileService.changePassword(
        newPassword: _newPasswordController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kata sandi berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui kata sandi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error changing password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          'Edit Profil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    icon: Icons.person,
                    title: 'Profil Pengguna',
                  ),
                  const SizedBox(height: 24),

                  // Profile Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4A4877).withOpacity(0.1),
                            border: Border.all(
                              color: const Color(0xFF4A4877).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(child: _buildProfileImage()),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isLoading ? null : _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isLoading
                                    ? Colors.grey
                                    : const Color(0xFF4A4877),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Profile Form
                  _buildTextFieldWithLabel(
                    label: 'Nama',
                    hint: 'Masukkan nama Anda',
                    controller: _namaProfileController,
                    prefixIcon: Icons.person_outline,
                  ),

                  const SizedBox(height: 32),

                  // Password Section
                  _buildSectionHeader(
                    icon: Icons.lock,
                    title: 'Ubah Kata Sandi',
                  ),
                  const SizedBox(height: 24),

                  _buildTextFieldWithLabel(
                    label: 'Kata Sandi Baru',
                    hint: 'Masukkan kata sandi baru',
                    controller: _newPasswordController,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureNewPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF9CA3AF),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextFieldWithLabel(
                    label: 'Konfirmasi Kata Sandi Baru',
                    hint: 'Konfirmasi kata sandi baru',
                    controller: _confirmPasswordController,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF9CA3AF),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Save Buttons
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLoading
                                  ? Colors.grey
                                  : const Color(0xFF4A4877),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Simpan Perubahan Profil',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLoading
                                  ? Colors.grey
                                  : const Color(0xFF4A4877),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Ubah Kata Sandi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Additional Profile Info
                  _buildInfoCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileImage() {
    print('Building profile image - Has URL: ${_profilePictureUrl != null}');

    if (kIsWeb) {
      if (_webImage != null) {
        return Image.memory(
          _webImage!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      }
    } else {
      if (_selectedImage != null) {
        return Image.file(
          _selectedImage!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      }
    }

    if (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty) {
      return Image.network(
        _profilePictureUrl!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        headers: {'User-Agent': 'Flutter App', 'Accept': 'image/*'},
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              color: const Color(0xFF4A4877),
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading profile image: $error');
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 40, color: Color(0xFF4A4877)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    setState(() {});
                  },
                  child: const Text(
                    'Tap to retry',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF4A4877),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return const Icon(Icons.person, size: 50, color: Color(0xFF4A4877));
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

  Widget _buildTextFieldWithLabel({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            enabled: !_isLoading,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              border: InputBorder.none,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: const Color(0xFF9CA3AF))
                  : null,
              suffixIcon: suffixIcon,
              contentPadding: EdgeInsets.symmetric(
                horizontal: prefixIcon != null ? 12 : 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              color: _isLoading ? Colors.grey : const Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4877).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A4877).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF4A4877),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informasi Profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A4877),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Nama, foto profil, dan kata sandi akan digunakan untuk identifikasi dalam aplikasi jadwal pelajaran. Pastikan data yang dimasukkan sudah benar.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
