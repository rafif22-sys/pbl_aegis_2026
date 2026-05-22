class BukuTamuModel {
  final int id;
  final String nama;
  final String jamMasuk;
  final String? jamKeluar;
  final String status;
  final int noAntrian;

  BukuTamuModel({
    required this.id,
    required this.nama,
    required this.jamMasuk,
    this.jamKeluar,
    required this.status,
    required this.noAntrian,
  });

  factory BukuTamuModel.fromJson(Map<String, dynamic> json) {
    return BukuTamuModel(
      id: json['id'],
      nama: json['nama'],
      jamMasuk: json['jam_masuk'],
      jamKeluar: json['jam_keluar'],
      status: json['status'],
      noAntrian: json['no_antrian'],
    );
  }
}
