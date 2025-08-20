import 'package:supabase_flutter/supabase_flutter.dart';

class MasterDataService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get all master jadwal
  static Future<List<Map<String, dynamic>>> getAllMasterJadwal() async {
    try {
      final response = await _client
          .from('master_jadwal')
          .select()
          .order('nama_pelajaran');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching master jadwal: $e');
      return [];
    }
  }

  // Add new master jadwal
  static Future<bool> addMasterJadwal({
    required String namaGuru,
    required String namaPelajaran,
    required String hexColor,
    required String waktuMulai,
    required String waktuSelesai,
  }) async {
    try {
      await _client.from('master_jadwal').insert({
        'nama_guru': namaGuru,
        'nama_pelajaran': namaPelajaran,
        'hex_color': hexColor,
        'waktu_mulai': waktuMulai,
        'waktu_selesai': waktuSelesai,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error adding master jadwal: $e');
      return false;
    }
  }

  // Delete master jadwal
  static Future<bool> deleteMasterJadwal(int id) async {
    try {
      await _client.from('master_jadwal').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting master jadwal: $e');
      return false;
    }
  }

  // Get master jadwal for dropdown
  static Future<List<Map<String, String>>> getMasterJadwalForDropdown() async {
    try {
      final response = await _client
          .from('master_jadwal')
          .select(
            'id, nama_guru, nama_pelajaran, hex_color, waktu_mulai, waktu_selesai',
          )
          .order('nama_pelajaran');
      return List<Map<String, String>>.from(
        response.map(
          (item) => {
            'id': item['id'].toString(),
            'nama_guru': item['nama_guru'].toString(),
            'nama_pelajaran': item['nama_pelajaran'].toString(),
            'hex_color': item['hex_color'].toString(),
            'waktu_mulai': item['waktu_mulai'].toString(),
            'waktu_selesai': item['waktu_selesai'].toString(),
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
      final user = _client.auth.currentUser;
      if (user == null) return 'Nama Pengguna';
      final response = await _client
          .from('users')
          .select('nama')
          .eq('id', user.id)
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
      final user = _client.auth.currentUser;
      if (user == null) return false;
      await _client.from('users').update({'nama': nama}).eq('id', user.id);
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
}
