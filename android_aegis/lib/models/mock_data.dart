import 'user_warga.dart';

class MockData {
  static final List<UserWarga> usersWarga = [
    UserWarga(
      id: 'w1',
      nama: 'Budi Santoso',
      email: 'budi@email.com',
      role: 'warga',
      noHp: '081234567890',
      alamat: 'Jl. Merdeka No. 10',
    ),
    UserWarga(
      id: 'w2',
      nama: 'Siti Rahayu',
      email: 'siti@email.com',
      role: 'warga',
      noHp: '081234567891',
      alamat: 'Jl. Sudirman No. 25',
    ),
  ];

  static final List<Map<String, dynamic>> usersPetugas = [
    {
      'id': 'p1',
      'nama': 'Andi Pratama',
      'email': 'andi@email.com',
      'role': 'petugas',
    },
  ];

  static final List<Map<String, dynamic>> usersSupervisor = [
    {
      'id': 's1',
      'nama': 'Dr. Siti Aminah',
      'email': 'siti.s@email.com',
      'role': 'supervisor',
    },
  ];

  static final List<Map<String, dynamic>> usersAdmin = [
    {
      'id': 'a1',
      'nama': 'Admin Utama',
      'email': 'admin@email.com',
      'role': 'admin',
    },
  ];

  static Map<String, dynamic>? findUserByEmail(String email) {
    for (var user in usersWarga) {
      if (user.email == email) return user.toJson();
    }
    for (var user in usersPetugas) {
      if (user['email'] == email) return user;
    }
    for (var user in usersSupervisor) {
      if (user['email'] == email) return user;
    }
    for (var user in usersAdmin) {
      if (user['email'] == email) return user;
    }
    return null;
  }
}
