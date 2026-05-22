import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../core/routes/app_routes.dart';

class WargaHomeScreen extends StatefulWidget {
  const WargaHomeScreen({super.key});

  @override
  State<WargaHomeScreen> createState() => _WargaHomeScreenState();
}

class _WargaHomeScreenState extends State<WargaHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SizedBox(), // Beranda
    const Center(
      child: Text(
        'Halaman Riwayat',
        style: TextStyle(fontSize: 20),
      ),
    ),
    const Center(
      child: Text(
        'Halaman Profil',
        style: TextStyle(fontSize: 20),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F2F9),

      body: _selectedIndex == 0
          ? SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  _buildHeader(user?.nama ?? '-'),

                  const SizedBox(height: 40),

                  _buildWelcomeCard(user),

                  const SizedBox(height: 30),

                  _buildMenuSection(),

                  const SizedBox(height: 20),
                ],
              ),
            )
          : _pages[_selectedIndex],

      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(String nama) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, bottom: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF142940),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/full Aegis.png',
            height: 150,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 20),

          Text(
            'Selamat Datang',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            nama,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.orange.withOpacity(0.5),
              ),
            ),
            child: const Text(
              'WARGA',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= WELCOME CARD =================

  Widget _buildWelcomeCard(user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2E8DF7),
              Color(0xFF1A67DD),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Akun',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 20),

            _buildInfoRow(Icons.email_outlined, user?.email ?? '-'),
            const SizedBox(height: 14),

            _buildInfoRow(Icons.phone_outlined, user?.noHp ?? '-'),
            const SizedBox(height: 14),

            _buildInfoRow(Icons.home_outlined, user?.alamat ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ================= MENU =================

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: _buildMenuCard(
                icon: Icons.history,
                title: 'Riwayat',
              ),
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: _buildMenuCard(
                icon: Icons.person_outline,
                title: 'Profil',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF90C2F9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2E8DF7),
              Color(0xFF1A67DD),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(25),
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
                color: const Color(0xFF1A67DD),
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

  // ================= BOTTOM NAVIGATION =================

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 15,
      ),
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
            icon: Icons.history,
            label: 'Riwayat',
            index: 1,
          ),

          _buildBottomNavItem(
            icon: Icons.person_outline,
            label: 'Profil',
            index: 2,
          ),
        ],
      ),
    );
  }

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
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
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? const Color(0xFF2280F0)
                  : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}