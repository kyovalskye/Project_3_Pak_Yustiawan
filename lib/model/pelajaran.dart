// model/pelajaran.dart
import 'package:flutter/material.dart';

class Pelajaran {
  final int? id;
  final String nama;
  final String jam;
  final Color warna;
  final String? namaHari;
  final String? waktuMulai;
  final String? waktuSelesai;

  const Pelajaran({
    this.id,
    required this.nama,
    required this.jam,
    required this.warna,
    this.namaHari,
    this.waktuMulai,
    this.waktuSelesai,
  });

  // Factory constructor to create Pelajaran from Supabase data
  factory Pelajaran.fromSupabase(Map<String, dynamic> data) {
    // Parse hex color string to Color
    String hexColor = data['hex_color'] ?? '0xFF6366F1';
    if (!hexColor.startsWith('0x')) {
      if (hexColor.startsWith('#')) {
        hexColor = '0xFF${hexColor.substring(1)}';
      } else {
        hexColor = '0xFF$hexColor';
      }
    }

    final color = Color(int.parse(hexColor));

    // Format time display
    final waktuMulai = data['waktu_mulai'] ?? '';
    final waktuSelesai = data['waktu_selesai'] ?? '';
    final jam = '$waktuMulai - $waktuSelesai';

    return Pelajaran(
      id: data['id'],
      nama: data['nama_kegiatan'] ?? '',
      jam: jam,
      warna: color,
      namaHari: data['nama_hari'],
      waktuMulai: waktuMulai,
      waktuSelesai: waktuSelesai,
    );
  }

  get namaKegiatan => null;

  // Convert to map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_kegiatan': nama,
      'nama_hari': namaHari,
      'waktu_mulai': waktuMulai,
      'waktu_selesai': waktuSelesai,
      'hex_color': '0x${warna.value.toRadixString(16).toUpperCase()}',
    };
  }
}
