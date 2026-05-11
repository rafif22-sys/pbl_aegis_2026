class SosReport {
  final String id;
  final String? userId;
  final DateTime waktu;
  final String status;
  final double? latitude;
  final double? longitude;
  final String? deskripsi;
  final List<String>? fotoUrls;
  final String? petugasId;
  final String? alamatKejadian;

  SosReport({
    required this.id,
    this.userId,
    required this.waktu,
    this.status = 'waiting',
    this.latitude,
    this.longitude,
    this.deskripsi,
    this.fotoUrls,
    this.petugasId,
    this.alamatKejadian,
  });

  factory SosReport.fromJson(Map<String, dynamic> json) {
    return SosReport(
      id: json['id'],
      userId: json['user_id'],
      waktu: DateTime.parse(json['waktu']),
      status: json['status'] ?? 'waiting',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      deskripsi: json['deskripsi'],
      fotoUrls: json['foto_urls'] != null
          ? List<String>.from(json['foto_urls'])
          : null,
      petugasId: json['petugas_id'],
      alamatKejadian: json['alamat_kejadian'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'waktu': waktu.toIso8601String(),
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'deskripsi': deskripsi,
      'foto_urls': fotoUrls,
      'petugas_id': petugasId,
      'alamat_kejadian': alamatKejadian,
    };
  }
}
