import 'package:camera/camera.dart';

class TamuRequestModel {
  final String nama;
  final String alamat;
  final String keperluan;
  final XFile fotoTamu;
  final String status;

  const TamuRequestModel({
    required this.nama,
    required this.alamat,
    required this.keperluan,
    required this.fotoTamu,
    this.status = 'masuk',
  });

  Map<String, String> toFields() {
    return {
      'nama': nama,
      'alamat': alamat,
      'keperluan': keperluan,
      'status': status,
    };
  }
}

class TamuUpdateRequestModel {
  final String status;
  final DateTime? waktuKeluar;

  const TamuUpdateRequestModel({required this.status, this.waktuKeluar});

  Map<String, String> toFields() {
    final fields = <String, String>{'status': status};

    if (waktuKeluar != null) {
      fields['waktu_keluar'] = waktuKeluar!.toIso8601String();
      fields['jam_keluar'] =
          '${waktuKeluar!.hour.toString().padLeft(2, '0')}:'
          '${waktuKeluar!.minute.toString().padLeft(2, '0')}';
    }

    return fields;
  }
}
