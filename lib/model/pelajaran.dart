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

  get namaKegiatan => null;
}
