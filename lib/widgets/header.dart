import 'package:flutter/material.dart';
import 'package:flutter_project3/services/user_session.dart';
import 'package:flutter_project3/pages/login_page.dart';
import 'package:flutter_project3/pages/settings_pages.dart';
import 'package:flutter_project3/pages/profile_pages.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderState extends State<Header> {
  @override
  void initState() {
    super.initState();
    // Set callback untuk auto-update saat UserSession berubah
    UserSession.setUpdateCallback(_onUserSessionUpdated);
  }

  @override
  void dispose() {
    // Clear callback saat widget di-dispose
    UserSession.clearUpdateCallback();
    super.dispose();
  }

  void _onUserSessionUpdated() {
    if (mounted) {
      setState(() {
        // Rebuild header dengan data terbaru
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Keluar'),
              onPressed: () {
                UserSession.clearSession();
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileAvatar(String? profilePictureUrl) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: ClipOval(
        child: profilePictureUrl != null && profilePictureUrl.isNotEmpty
            ? Image.network(
                profilePictureUrl,
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                headers: {'User-Agent': 'Flutter App', 'Accept': 'image/*'},
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, color: Colors.white, size: 20),
              )
            : const Icon(Icons.person, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildPopupMenuProfileAvatar(String? profilePictureUrl) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withOpacity(0.2),
      ),
      child: ClipOval(
        child: profilePictureUrl != null && profilePictureUrl.isNotEmpty
            ? Image.network(
                profilePictureUrl,
                width: 20,
                height: 20,
                fit: BoxFit.cover,
                headers: {'User-Agent': 'Flutter App', 'Accept': 'image/*'},
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, color: Colors.grey, size: 14),
              )
            : const Icon(Icons.person, color: Colors.grey, size: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = UserSession.getCurrentUserName() ?? 'User';
    final profilePictureUrl = UserSession.getCurrentUserProfilePicture();

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Jadwal Pembelajaran',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Hi, $userName!',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      centerTitle: false,
      backgroundColor: const Color(0xFF4A4877),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: PopupMenuButton<String>(
            icon: _buildProfileAvatar(profilePictureUrl),
            onSelected: (String value) async {
              if (value == 'logout') {
                _showLogoutDialog(context);
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              } else if (value == 'profile') {
                // Handle result dari ProfilePage untuk update header
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );

                // Jika profile diupdate, setState sudah dipanggil otomatis
                // via UserSession callback, tapi kita bisa tambahkan manual refresh
                if (result == true && mounted) {
                  setState(() {
                    // Force rebuild dengan data terbaru
                  });
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    _buildPopupMenuProfileAvatar(profilePictureUrl),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Profil ($userName)',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          // Hapus tampilan URL - hanya tampilkan status
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Master Data'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Keluar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
    );
  }
}
