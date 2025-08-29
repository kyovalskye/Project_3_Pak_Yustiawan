import '../supabase/supabase_connect.dart';
import '../services/user_session.dart';

class MasterDataService {
  static get _client => DatabaseConfig.client;

  // Get current user ID from session (konsisten dengan supabase_services.dart)
  static String? getCurrentUserId() {
    return UserSession.getCurrentUserId();
  }

  // Check if user is authenticated
  static bool isUserAuthenticated() {
    return UserSession.isLoggedIn();
  }

  // Get all master jadwal for current user only
  static Future<List<Map<String, dynamic>>> getAllMasterJadwal() async {
    try {
      final currentUserId = getCurrentUserId();

      if (currentUserId == null) {
        throw Exception('User tidak login');
      }

      final response = await _client
          .from('master_jadwal')
          .select('*')
          .eq('user_id', currentUserId) // Filter by current user ID
          .order('nama_pelajaran');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting master jadwal: $e');
      return [];
    }
  }

  // Add new master jadwal for current user
  static Future<bool> addMasterJadwal({
    required String namaGuru,
    required String namaPelajaran,
    required String hexColor,
  }) async {
    try {
      final currentUserId = getCurrentUserId();

      if (currentUserId == null) {
        throw Exception('User tidak login');
      }

      await _client.from('master_jadwal').insert({
        'user_id': currentUserId, // Add user ID to the master schedule
        'nama_guru': namaGuru,
        'nama_pelajaran': namaPelajaran,
        'hex_color': hexColor,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error adding master jadwal: $e');
      return false;
    }
  }

  // Update master jadwal (only if it belongs to current user)
  static Future<bool> updateMasterJadwal({
    required int id,
    required String namaGuru,
    required String namaPelajaran,
    required String hexColor,
  }) async {
    try {
      final currentUserId = getCurrentUserId();

      if (currentUserId == null) {
        throw Exception('User tidak login');
      }

      // First check if the master schedule belongs to the current user
      final existing = await _client
          .from('master_jadwal')
          .select('user_id')
          .eq('id', id)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existing == null) {
        throw Exception(
          'Master jadwal tidak ditemukan atau tidak dapat diakses',
        );
      }

      await _client
          .from('master_jadwal')
          .update({
            'nama_guru': namaGuru,
            'nama_pelajaran': namaPelajaran,
            'hex_color': hexColor,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', currentUserId); // Double check user ownership

      return true;
    } catch (e) {
      print('Error updating master jadwal: $e');
      return false;
    }
  }

  // Delete master jadwal (only if it belongs to current user)
  static Future<bool> deleteMasterJadwal(int id) async {
    try {
      final currentUserId = getCurrentUserId();

      if (currentUserId == null) {
        throw Exception('User tidak login');
      }

      // First check if the master schedule belongs to the current user
      final existing = await _client
          .from('master_jadwal')
          .select('user_id')
          .eq('id', id)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existing == null) {
        throw Exception(
          'Master jadwal tidak ditemukan atau tidak dapat diakses',
        );
      }

      await _client
          .from('master_jadwal')
          .delete()
          .eq('id', id)
          .eq('user_id', currentUserId); // Double check user ownership

      return true;
    } catch (e) {
      print('Error deleting master jadwal: $e');
      return false;
    }
  }

  // Get master jadwal for dropdown (current user only)
  static Future<List<Map<String, String>>> getMasterJadwalForDropdown() async {
    try {
      final currentUserId = getCurrentUserId();

      if (currentUserId == null) {
        throw Exception('User tidak login');
      }

      final response = await _client
          .from('master_jadwal')
          .select('id, nama_guru, nama_pelajaran, hex_color')
          .eq('user_id', currentUserId) // Filter by current user ID
          .order('nama_pelajaran');

      return List<Map<String, String>>.from(
        response.map(
          (item) => {
            'id': item['id'].toString(),
            'nama_guru': item['nama_guru'].toString(),
            'nama_pelajaran': item['nama_pelajaran'].toString(),
            'hex_color': item['hex_color'].toString(),
          },
        ),
      );
    } catch (e) {
      print('Error fetching master jadwal for dropdown: $e');
      return [];
    }
  }

  // Get user profile
  static Future<String> getUserProfile() async {
    try {
      final currentUserId = getCurrentUserId();
      if (currentUserId == null) return 'Nama Pengguna';

      final response = await _client
          .from('users')
          .select('nama')
          .eq('user_id', currentUserId)
          .single();

      return response['nama']?.toString() ?? 'Nama Pengguna';
    } catch (e) {
      print('Error fetching user profile: $e');
      return 'Nama Pengguna';
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile(String nama) async {
    try {
      final currentUserId = getCurrentUserId();
      if (currentUserId == null) return false;

      await _client
          .from('users')
          .update({'nama': nama})
          .eq('user_id', currentUserId);

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Check if current user is the creator of a master jadwal
  static Future<bool> isUserCreator(int masterJadwalId) async {
    try {
      final currentUserId = getCurrentUserId();
      if (currentUserId == null) return false;

      final response = await _client
          .from('master_jadwal')
          .select('user_id')
          .eq('id', masterJadwalId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking user creator status: $e');
      return false;
    }
  }
}
