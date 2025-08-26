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
  String? _profilePictureUrl;
  File? _selectedImage;
  Uint8List? _webImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _namaProfileController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load fresh data from database
      final user = await ProfileService.getUserProfile();
      if (user != null) {
        setState(() {
          _namaProfileController.text = user['nama'] ?? 'Nama Pengguna';
          _profilePictureUrl = user['profile_picture'];
        });

        // Update session with fresh data
        UserSession.setCurrentUser(user);
        print(
          'Profile loaded - Picture URL: ${user['profile_picture']}',
        ); // Debug log
      } else {
        // Fallback to session data if database call fails
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
      // Fallback to session data
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // For web platform
        final webImage = await pickedFile.readAsBytes();
        setState(() {
          _webImage = webImage;
          _selectedImage = null;
        });
      } else {
        // For mobile platforms
        setState(() {
          _selectedImage = File(pickedFile.path);
          _webImage = null;
        });
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

      // Handle image upload for both web and mobile
      if (kIsWeb && _webImage != null) {
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
        print('Web upload success - URL: $profilePictureUrl'); // Debug log
      } else if (!kIsWeb && _selectedImage != null) {
        profilePictureUrl = await ProfileService.uploadProfilePicture(
          _selectedImage!.path,
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
        print('Mobile upload success - URL: $profilePictureUrl'); // Debug log
      }

      // Update profile in database
      final success = await ProfileService.updateUserProfile(
        nama: _namaProfileController.text.trim(),
        profilePictureUrl: profilePictureUrl,
      );

      if (success) {
        // Reload fresh data from database and update session
        final updatedUser = await ProfileService.getUserProfile();
        if (updatedUser != null) {
          UserSession.setCurrentUser(updatedUser);
          print(
            'Session updated - Picture URL: ${updatedUser['profile_picture']}',
          ); // Debug log

          // Trigger rebuild of any widgets that depend on UserSession
          // This will update the header immediately
          if (mounted) {
            // Force a rebuild of the parent widget if possible
            Navigator.of(
              context,
            ).pop(true); // Return true to indicate profile was updated
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

                  // Save Button
                  Center(
                    child: SizedBox(
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
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
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

  // Enhanced method to handle profile image display for both web and mobile
  Widget _buildProfileImage() {
    // Debug log (without URL to avoid showing it in UI)
    print('Building profile image - Has URL: ${_profilePictureUrl != null}');

    if (kIsWeb) {
      // Web platform - show newly selected image first
      if (_webImage != null) {
        return Image.memory(
          _webImage!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      }
    } else {
      // Mobile platform - show newly selected image first
      if (_selectedImage != null) {
        return Image.file(
          _selectedImage!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      }
    }

    // Show existing network image if available
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
          // Don't print URL in error to avoid showing it in logs/UI
          print('Error loading profile image');

          // Show retry button for network errors
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
                    setState(() {
                      // Force rebuild to retry loading
                    });
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

    // Default icon
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
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              border: InputBorder.none,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: const Color(0xFF9CA3AF))
                  : null,
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
            'Nama dan foto profil akan digunakan untuk identifikasi dalam aplikasi jadwal pelajaran. Pastikan data yang dimasukkan sudah benar.',
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
