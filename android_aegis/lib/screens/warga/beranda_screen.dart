import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'laporan_screen.dart';
import 'riwayat_screen.dart';
import 'sos_form_screen.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  void _showSosForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SOSFormScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              color: Color(0xFF102a43),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.shield,
                  size: 80,
                  color: Color(0xFF40a9ff),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A E G I S',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Advanced Emergency\n& Guard Information System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildButton(
                        context,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFff4d4d), Color(0xFFf06292)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderColor: const Color(0xFFffcdd2),
                        title: 'KIRIM SOS',
                        icon: Icons.shield_outlined,
                        onTap: () => _showSosForm(context),
                      ),
                      const SizedBox(height: 20),
                      _buildButton(
                        context,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196f3), Color(0xFF4dabf5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderColor: const Color(0xFFbbdefb),
                        title: 'LAPORAN',
                        icon: Icons.description_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LaporanScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required Gradient gradient,
    required Color borderColor,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: borderColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            Icon(icon, size: 30, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
