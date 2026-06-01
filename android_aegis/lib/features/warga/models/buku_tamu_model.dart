const String _supabaseStorageUrl =
    'https://dwyfjwwgrtdspgdaifyv.supabase.co/storage/v1/object/public/aegis/';

String? _buildFotoUrl(String? raw) {
  if (raw == null) return null;
  if (raw.startsWith('http')) return raw;
  return '$_supabaseStorageUrl$raw';
}

class BukuTamuModel {
  final int id;
  final int? idUser;
  final String nama;
  final String? alamat;
  final String? keperluan;
  final String? fotoTamu;
  final String waktuMasuk;
  final String? waktuKeluar;
  final String status;
  final String namaUser;

  BukuTamuModel({
    required this.id,
    this.idUser,
    required this.nama,
    this.alamat,
    this.keperluan,
    this.fotoTamu,
    required this.waktuMasuk,
    this.waktuKeluar,
    required this.status,
    this.namaUser = '-',
  });

  factory BukuTamuModel.fromJson(Map<String, dynamic> json) {
    return BukuTamuModel(
      id: json['id'],
      idUser: json['id_user'],
      nama: json['nama'] ?? '',
      alamat: json['alamat'],
      keperluan: json['keperluan'],
      fotoTamu: _buildFotoUrl(json['foto_tamu'] as String?),
      waktuMasuk: json['waktu_masuk'] ?? '',
      waktuKeluar: json['waktu_keluar'],
      status: json['status'] ?? '',
      namaUser: json['user']?['nama'] as String? ?? '-',
    );
  }
}
