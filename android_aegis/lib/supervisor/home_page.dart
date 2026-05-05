import 'package:flutter/material.dart';
import 'sos_form.dart';
import 'laporan_page.dart';
import 'jadwal_page.dart';
import 'riwayat_page.dart';
import 'profil_page.dart';
import 'informasi_page.dart';
import 'buku_tamu_page.dart';

class SupervisorHomePage extends StatefulWidget {
  const SupervisorHomePage({super.key});

  @override
  State<SupervisorHomePage> createState() => _SupervisorHomePageState();
}

class _SupervisorHomePageState extends State<SupervisorHomePage> {
  // Variabel untuk melacak tab yang aktif di Bottom Navigation
  int _selectedIndex = 0;

  // Daftar halaman untuk setiap tab di Bottom Navigation
  final List<Widget> _pages = [
    const SizedBox(), // Index 0: Dikosongkan sementara untuk Beranda (Dashboard)
    const JadwalPage(), // Index 1: Halaman Jadwal
    const RiwayatPage(), // Index 2
    const InformasiPage(), // Index 3
    const ProfilPage(), // Index 4
    const BukuTamuPage(), // Index 5: Halaman Buku Tamu
    const LaporanPage(), // Index 6: Halaman Laporan
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F2F9),
      body: _selectedIndex == 0
          ? SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // MEMANGGIL TOMBOL SOS
                  _buildSOSButton(),
                  const SizedBox(height: 24),

                  // MEMANGGIL MENU BUKU TAMU & LAPORAN
                  _buildActionButtons(),

                  const SizedBox(height: 40),
                ],
              ),
            )
          : _pages[_selectedIndex],

      // MEMANGGIL CUSTOM BOTTOM NAV BUATANMU
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- WIDGET HEADER (Bagian Biru Tua & Logo Supabase) ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, bottom: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF142940), // Warna biru dongker
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          // Mengambil logo langsung dari Storage Supabase
          Image.network(
            'https://dwyfjwwgrtdspgdaifyv.supabase.co/storage/v1/object/public/logo/aegis_full_logo.png',
            height: 240, // Silakan sesuaikan tingginya jika kurang besar/kecil
            fit: BoxFit.contain,
            // Tambahkan loading builder biar nggak blank saat internet lambat
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                height: 240,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.lightBlueAccent,
                  ),
                ),
              );
            },
            // Penanganan jika link error/berubah
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.broken_image,
                color: Colors.white54,
                size: 80,
              );
            },
          ),
        ],
      ),
    );
  }

  // --- WIDGET TOMBOL SOS ---
  Widget _buildSOSButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SOSFormPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF09FA6).withOpacity(0.5),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFED4D5C), Color(0xFFF27855)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.shield_outlined, size: 60, color: Colors.white),
                Text(
                  'SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET TOMBOL MENU (Buku Tamu & Laporan) ---
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BukuTamuPage()),
                );
              },
              child: _buildMenuCard(
                icon: Icons.badge_outlined,
                title: 'Buku Tamu',
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LaporanPage()),
                );
              },
              child: _buildMenuCard(
                icon: Icons.insert_chart_outlined,
                title: 'Laporan',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Komponen satuan untuk Tombol Menu
  Widget _buildMenuCard({required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.all(8), // Padding untuk efek border tebal
      decoration: BoxDecoration(
        color: const Color(
          0xFF90C2F9,
        ).withOpacity(0.5), // Border luar biru muda pudar
        borderRadius: BorderRadius.circular(35),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E8DF7), Color(0xFF1A67DD)], // Gradient Biru
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 36,
                color: const Color(0xFF1A67DD), // Icon berwarna biru
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET CUSTOM BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBottomNavItem(
            icon: Icons.home_filled,
            label: 'Beranda',
            index: 0,
          ),
          _buildBottomNavItem(
            icon: Icons.calendar_month,
            label: 'Jadwal',
            index: 1,
          ),
          _buildBottomNavItem(
            icon: Icons.warning_amber_rounded,
            label: 'Riwayat',
            index: 2,
          ),
          _buildBottomNavItem(
            icon: Icons.info_outline,
            label: 'Informasi',
            index: 3,
          ),
          _buildBottomNavItem(
            icon: Icons.person_outline,
            label: 'Profil',
            index: 4,
          ),
        ],
      ),
    );
  }

  // Komponen satuan untuk item Bottom Navigation
  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent, // Agar area kliknya lebih luas
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE4F1FA)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 26,
                color: isSelected
                    ? const Color(0xFF2280F0)
                    : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF2280F0)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
