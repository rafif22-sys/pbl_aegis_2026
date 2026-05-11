class UserWarga {
  final String id;
  final String nama;
  final String email;
  final String role;
  final String noHp;
  final String alamat;

  UserWarga({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    required this.noHp,
    required this.alamat,
  });

  factory UserWarga.fromJson(Map<String, dynamic> json) {
    return UserWarga(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      role: json['role'],
      noHp: json['noHp'],
      alamat: json['alamat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'noHp': noHp,
      'alamat': alamat,
    };
  }
}
