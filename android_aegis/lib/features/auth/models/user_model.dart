class UserModel {
  final int id;
  final String nama;
  final String email;
  final String role;
  final String? tanggalLahir;
  final String? alamat;
  final String? noHp;
  final String? fotoProfil;
  final String? tanggalBergabung;
  final String? wilayahPengawasan;
  final Map<String, dynamic>? supervisor;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.tanggalLahir,
    this.alamat,
    this.noHp,
    this.fotoProfil,
    this.tanggalBergabung,
    this.wilayahPengawasan,
    this.supervisor,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      role: json['role'],
      tanggalLahir: json['tanggal_lahir'],
      alamat: json['alamat'],
      noHp: json['no_hp'],
      fotoProfil: json['foto_profil'],
      tanggalBergabung: json['tanggal_bergabung'],
      wilayahPengawasan: json['wilayah_pengawasan'],
      supervisor: json['supervisor'],
    );
  }
}