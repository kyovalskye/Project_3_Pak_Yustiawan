//supabase_services.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get all jadwal kegiatan
  static Future<List<Map<String, dynamic>>> getAllJadwal() async {
    try {
      final response = await _client
          .from('jadwal_kegiatan')
          .select()
          .order('nama_hari')
          .order('waktu_mulai');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching jadwal: $e');
      return [];
    }
  }

  // Add new jadwal kegiatan
  static Future<bool> addJadwal({
    required String namaHari,
    required String namaKegiatan,
    required String waktuMulai,
    required String waktuSelesai,
    required String hexColor,
    String? namaGuru, // Added teacher name parameter
  }) async {
    try {
      await _client.from('jadwal_kegiatan').insert({
        'nama_hari': namaHari,
        'nama_kegiatan': namaKegiatan,
        'waktu_mulai': waktuMulai,
        'waktu_selesai': waktuSelesai,
        'hex_color': hexColor,
        'nama_guru': namaGuru, // Insert teacher name
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error adding jadwal: $e');
      return false;
    }
  }

  // Check for schedule conflicts
  static Future<bool> checkScheduleConflict({
    required String namaHari,
    required String waktuMulai,
    required String waktuSelesai,
  }) async {
    try {
      final response = await _client
          .from('jadwal_kegiatan')
          .select('waktu_mulai, waktu_selesai')
          .eq('nama_hari', namaHari);

      final existingSchedules = List<Map<String, dynamic>>.from(response);

      for (final schedule in existingSchedules) {
        final existingStart = _parseTimeToMinutes(schedule['waktu_mulai']);
        final existingEnd = _parseTimeToMinutes(schedule['waktu_selesai']);
        final newStart = _parseTimeToMinutes(waktuMulai);
        final newEnd = _parseTimeToMinutes(waktuSelesai);

        if (newStart < existingEnd && newEnd > existingStart) {
          return true; // Conflict found
        }
      }

      return false; // No conflict
    } catch (e) {
      print('Error checking conflict: $e');
      return false;
    }
  }

  // Check for schedule conflicts excluding current schedule being updated
  static Future<bool> checkScheduleConflictForUpdate({
    required int id,
    required String namaHari,
    required String waktuMulai,
    required String waktuSelesai,
  }) async {
    try {
      final response = await _client
          .from('jadwal_kegiatan')
          .select('waktu_mulai, waktu_selesai')
          .eq('nama_hari', namaHari)
          .neq('id', id); // Exclude the current schedule being updated

      final existingSchedules = List<Map<String, dynamic>>.from(response);

      for (final schedule in existingSchedules) {
        final existingStart = _parseTimeToMinutes(schedule['waktu_mulai']);
        final existingEnd = _parseTimeToMinutes(schedule['waktu_selesai']);
        final newStart = _parseTimeToMinutes(waktuMulai);
        final newEnd = _parseTimeToMinutes(waktuSelesai);

        if (newStart < existingEnd && newEnd > existingStart) {
          return true; // Conflict found
        }
      }

      return false; // No conflict
    } catch (e) {
      print('Error checking conflict for update: $e');
      return false;
    }
  }

  // Helper method to convert time string to minutes
  static int _parseTimeToMinutes(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  // Delete jadwal by ID
  static Future<bool> deleteJadwal(int id) async {
    try {
      await _client.from('jadwal_kegiatan').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting jadwal: $e');
      return false;
    }
  }

  // Update jadwal
  static Future<bool> updateJadwal({
    required int id,
    required String namaHari,
    required String namaKegiatan,
    required String waktuMulai,
    required String waktuSelesai,
    required String hexColor,
    String? namaGuru, // Added teacher name parameter
  }) async {
    try {
      await _client
          .from('jadwal_kegiatan')
          .update({
            'nama_hari': namaHari,
            'nama_kegiatan': namaKegiatan,
            'waktu_mulai': waktuMulai,
            'waktu_selesai': waktuSelesai,
            'hex_color': hexColor,
            'nama_guru': namaGuru, // Update teacher name
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      return true;
    } catch (e) {
      print('Error updating jadwal: $e');
      return false;
    }
  }
}
