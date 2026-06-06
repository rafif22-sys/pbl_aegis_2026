// lib/features/petugas/models/patroli_model.dart

class PatroliModel {
  final int    idJadwalAbsensi;
  final String namaRute;
  final String deskripsiRute;
  final String namaShift;      
  final String jamShift;       
  final List<CheckpointPatroli> checkpoints;
  final List<PolylinePoint>     polyline;

  PatroliModel({
    required this.idJadwalAbsensi,
    required this.namaRute,
    required this.deskripsiRute,
    required this.namaShift,
    required this.jamShift,
    required this.checkpoints,
    required this.polyline,
  });

  factory PatroliModel.fromJson(Map<String, dynamic> json) {
    return PatroliModel(
      idJadwalAbsensi: json['id_jadwal_absensi'],
      namaRute:        json['nama_rute']      ?? '',
      deskripsiRute:   json['deskripsi_rute'] ?? '',
      namaShift:       json['nama_shift']     ?? '',
      jamShift:        json['jam_shift']      ?? '',
      checkpoints: (json['checkpoints'] as List<dynamic>)
          .map((e) => CheckpointPatroli.fromJson(e))
          .toList(),
      polyline: (json['polyline'] as List<dynamic>? ?? [])
          .map((e) => PolylinePoint.fromJson(e))
          .toList(),
    );
  }
}

class CheckpointPatroli {
  final int    id;
  final int    idCheckpoint;
  final int    urutan;
  final String namaCheckpoint;
  final double latitude;
  final double longitude;
  final String? deskripsi;
  LaporanCheckpointStatus? laporan;

  CheckpointPatroli({
    required this.id,
    required this.idCheckpoint,
    required this.urutan,
    required this.namaCheckpoint,
    required this.latitude,
    required this.longitude,
    this.deskripsi,
    this.laporan,
  });

  bool get sudahDilaporkan => laporan != null;

  factory CheckpointPatroli.fromJson(Map<String, dynamic> json) {
    return CheckpointPatroli(
      id:             json['id'],
      idCheckpoint:   json['id_checkpoint'],
      urutan:         json['urutan'],
      namaCheckpoint: json['nama_checkpoint'] ?? '',
      latitude:       (json['latitude']  as num).toDouble(),
      longitude:      (json['longitude'] as num).toDouble(),
      deskripsi:      json['deskripsi'],
      laporan: json['laporan'] != null
          ? LaporanCheckpointStatus.fromJson(json['laporan'])
          : null,
    );
  }
}

class LaporanCheckpointStatus {
  final int    id;
  final String kondisi;
  final String status;

  LaporanCheckpointStatus({
    required this.id,
    required this.kondisi,
    required this.status,
  });

  factory LaporanCheckpointStatus.fromJson(Map<String, dynamic> json) {
    return LaporanCheckpointStatus(
      id:      json['id'],
      kondisi: json['kondisi'] ?? '',
      status:  json['status']  ?? '',
    );
  }
}

class PolylinePoint {
  final double latitude;
  final double longitude;

  PolylinePoint({required this.latitude, required this.longitude});

  factory PolylinePoint.fromJson(Map<String, dynamic> json) {
    return PolylinePoint(
      latitude:  (json['latitude']  as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}