import '../supabase/supabase_connect.dart';
import '../services/user_session.dart';

class SupabaseService {
  static get _client => DatabaseConfig.client;

  // Get all schedules for current user only
  static Future<List<Map<String, dynamic>>> getAllJadwal() async {
    try {
      final currentUserId = UserSession.getCurrentUserId();

      if (currentUserId == null) {
        throw Exception('User tidak login');
      }

      final response = await _client
          .from('jadwal_kegiatan')
          .select('*')
          .eq('user_id', currentUserId) // Filter by current user ID
          .order('waktu_mulai');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting jadwal: $e');
      rethrow;
    }
  }

  // Get schedules for a specific day for current user
  static Future<List<Map<String, dynamic>>> getJadwalByHari(String hari) async {
    try {
      final currentUserId = UserSession.getCurrentUserId();

      if (currentUserId == null) {
        throw Exception('User tidak login');
      }

      final response = await _client
          .from('jadwal_kegiatan')
          .select('*')
          .eq('user_id', currentUserId) // Filter by current user ID
          .eq('nama_hari', hari)
          .order('waktu_mulai');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting jadwal by hari: $e');
      rethrow;
    }
  }

  // Add new schedule for current user
  static Future<bool> addJadwal({
    required String namaHari,
    required String namaKegiatan,
    required String waktuMulai,
    required String waktuSelesai,
    required String hexColor,
    String? namaGuru,
  }) async {
    try {
      final currentUserId = UserSession.getCurrentUserId();

      if (currentUserId == null) {
        throw Exception('User tidak login');
      }

      await _client.from('jadwal_kegiatan').insert({
        'user_id': currentUserId, // Add user ID to the schedule
        'nama_hari': namaHari,
        'nama_kegiatan': namaKegiatan,
        'waktu_mulai': waktuMulai,
        'waktu_selesai': waktuSelesai,
        'hex_color': hexColor,
        'nama_guru': namaGuru,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error adding jadwal: $e');
      return false;
    }
  }

  // Update schedule (only if it belongs to current user)
  static Future<bool> updateJadwal({
    required int id,
    required String namaHari,
    required String namaKegiatan,
    required String waktuMulai,
    required String waktuSelesai,
    required String hexColor,
    String? namaGuru,
  }) async {
    try {
      final currentUserId = UserSession.getCurrentUserId();

      if (currentUserId == null) {
        throw Exception('User tidak login');
      }

      // First check if the schedule belongs to the current user
      final existing = await _client
          .from('jadwal_kegiatan')
          .select('user_id')
          .eq('id', id)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existing == null) {
        throw Exception('Jadwal tidak ditemukan atau tidak dapat diakses');
      }

      await _client
          .from('jadwal_kegiatan')
          .update({
            'nama_hari': namaHari,
            'nama_kegiatan': namaKegiatan,
            'waktu_mulai': waktuMulai,
            'waktu_selesai': waktuSelesai,
            'hex_color': hexColor,
            'nama_guru': namaGuru,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', currentUserId); // Double check user ownership

      return true;
    } catch (e) {
      print('Error updating jadwal: $e');
      return false;
    }
  }

  // Delete schedule (only if it belongs to current user)
  static Future<bool> deleteJadwal(int id) async {
    try {
      final currentUserId = UserSession.getCurrentUserId();

      if (currentUserId == null) {
        throw Exception('User tidak login');
      }

      // First check if the schedule belongs to the current user
      final existing = await _client
          .from('jadwal_kegiatan')
          .select('user_id')
          .eq('id', id)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existing == null) {
        throw Exception('Jadwal tidak ditemukan atau tidak dapat diakses');
      }

      await _client
          .from('jadwal_kegiatan')
          .delete()
          .eq('id', id)
          .eq('user_id', currentUserId); // Double check user ownership

      return true;
    } catch (e) {
      print('Error deleting jadwal: $e');
      return false;
    }
  }
}
