import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'daftar_petugas_page.dart';
import '../../auth/providers/auth_provider.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4F0FB), // Background biru muda Aegis
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100), // Ruang untuk BottomNav
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildStatsRow(),
                    const SizedBox(height: 30),
                    _buildMenuContainer(context),
                    
                    const SizedBox(height: 30), // Jarak sebelum tombol logout
                    // --- PEMANGGILAN TOMBOL LOGOUT ---
                    const TombolLogoutSupervisor(), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: Row(
        children: [
          // Logo Kecil dari Supabase
          Image.network(
            'https://dwyfjwwgrtdspgdaifyv.supabase.co/storage/v1/object/public/logo/aegis-nobg.png',
            height: 24,
            width: 24,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, color: Colors.lightBlueAccent, size: 24),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'ADVANCED EMERGENCY & GUARD INFORMATION SYSTEM',
              style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            image: const DecorationImage(
              image: NetworkImage('https://randomuser.me/api/portraits/men/46.jpg'), // Placeholder Ganjar Subianto
              fit: BoxFit.cover,
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Ganjar Subianto', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        const Text('Supervisor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2), // Biru
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: const Column(
                children: [
                  Text('Jumlah Petugas', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Icon(Icons.support_agent, color: Colors.white, size: 40),
                  SizedBox(height: 8),
                  Text('32', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: const Column(
                children: [
                  Text('Laporan Diterima', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Icon(Icons.shield_outlined, color: Colors.white, size: 40),
                  SizedBox(height: 8),
                  Text('220', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.people_alt,
            title: 'Daftar Petugas',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarPetugasPage()));
            },
          ),
          _buildDivider(),
          _buildMenuItem(icon: Icons.person, title: 'Data Diri', onTap: () {}),
          _buildDivider(),
          _buildMenuItem(icon: Icons.lock, title: 'Keamanan', onTap: () {}),
          _buildDivider(),
          _buildMenuItem(icon: Icons.info_outline, title: 'Tentang Aplikasi', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE4F0FB),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Icon(icon, color: const Color(0xFF1976D2), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Color(0xFFEEEEEE)),
    );
  }
}

// ─── IMPLEMENTASI WIDGET TOMBOL LOGOUT ───────────────────────────────────────
class TombolLogoutSupervisor extends StatelessWidget {
  const TombolLogoutSupervisor({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        // 1. Munculkan pop-up konfirmasi
        final bool? konfirmasi = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Konfirmasi Keluar'),
              content: const Text('Apakah Anda yakin ingin keluar dari akun Supervisor?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );

        // 2. Jika klik "Keluar", jalankan fungsi dari AuthProvider
        if (konfirmasi == true && context.mounted) {
          final authProvider = context.read<AuthProvider>();
          
          // Proses menghapus token di Supabase & memori HP
          await authProvider.logout();

          // 3. Lempar paksa kembali ke halaman Login dan hapus tumpukan histori halaman
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red.shade700,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.red.shade200),
        ),
      ),
      icon: const Icon(Icons.logout),
      label: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}