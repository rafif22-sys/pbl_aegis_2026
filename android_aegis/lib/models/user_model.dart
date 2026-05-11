class UserModel {
  final String id;
  final String email;
  final String nama;
  final String role;
  final String? noHp;
  final String? alamat;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.nama,
    required this.role,
    this.noHp,
    this.alamat,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      nama: json['nama'],
      role: json['role'],
      noHp: json['no_hp'],
      alamat: json['alamat'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama': nama,
      'role': role,
      'no_hp': noHp,
      'alamat': alamat,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
