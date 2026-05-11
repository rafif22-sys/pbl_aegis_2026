import 'package:flutter/material.dart';

class RiwayatLaporanScreen extends StatelessWidget {
  const RiwayatLaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f7ff),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, size: 24),
                  ),
                  const Text(
                    'Laporan Patroli',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Minggu Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  '',
                  style: TextStyle(fontSize: 10),
                ),
              ),
              Expanded(
                child: ListView(
                  children: const [
                    _ReportCard(
                      day: 'Jumat',
                      fullDate: '14 April 2026',
                      totalPatroli: 10,
                      petugas: 24,
                      checkpoint: 24,
                    ),
                    _ReportCard(
                      day: 'Kamis',
                      fullDate: '13 April 2026',
                      totalPatroli: 10,
                      petugas: 24,
                      checkpoint: 24,
                    ),
                    _ReportCard(
                      day: 'Rabu',
                      fullDate: '12 April 2026',
                      totalPatroli: 8,
                      petugas: 20,
                      checkpoint: 20,
                    ),
                    SizedBox(height: 20),
                    _SearchBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String day;
  final String fullDate;
  final int totalPatroli;
  final int petugas;
  final int checkpoint;

  const _ReportCard({
    required this.day,
    required this.fullDate,
    required this.totalPatroli,
    required this.petugas,
    required this.checkpoint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0d47a1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fullDate,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              children: [
                _infoRow(Icons.check_box_outlined, 'Total Patroli', '$totalPatroli'),
                _infoRow(Icons.person_outline, 'Petugas', '$petugas'),
                _infoRow(Icons.location_on, 'Total Checkpoint', '$checkpoint'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.calendar_today_outlined, color: Colors.grey),
          SizedBox(width: 10),
          Text(
            'Cari Tanggal',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
