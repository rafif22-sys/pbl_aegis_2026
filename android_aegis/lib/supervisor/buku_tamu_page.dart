import 'package:flutter/material.dart';

// --- MODEL DATA BUKU TAMU ---
class TamuData {
  final String nama;
  final String jamMasuk;
  final String jamKeluar;
  final String status; // 'Masuk' atau 'Keluar'
  final String noUrut;

  TamuData({
    required this.nama,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.status,
    required this.noUrut,
  });
}

class BukuTamuPage extends StatefulWidget {
  const BukuTamuPage({super.key});

  @override
  State<BukuTamuPage> createState() => _BukuTamuPageState();
}

class _BukuTamuPageState extends State<BukuTamuPage> {
  // Data Dummy sesuai gambar
  final List<TamuData> listTamu = [
    TamuData(nama: 'Budi Prakoso', jamMasuk: '10:20', jamKeluar: '10:20', status: 'Keluar', noUrut: '111'),
    TamuData(nama: 'Andi Surandi', jamMasuk: '10:20', jamKeluar: '-', status: 'Masuk', noUrut: '112'),
    TamuData(nama: 'Budiono Simanjuntak', jamMasuk: '10:20', jamKeluar: '10:20', status: 'Keluar', noUrut: '111'),
    TamuData(nama: 'Bambang Pamungkas', jamMasuk: '10:20', jamKeluar: '-', status: 'Masuk', noUrut: '112'),
    TamuData(nama: 'Putra Surya', jamMasuk: '10:20', jamKeluar: '10:20', status: 'Keluar', noUrut: '111'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4F0FB), // Biru muda Aegis
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            _buildTitleBar(context),
            _buildDateFilter(), // <--- Ini komponen Pilih Tanggal yang bisa kamu pakai ulang
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 20),
            
            // Container Putih Pembungkus List
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ListView.builder(
                  itemCount: listTamu.length,
                  itemBuilder: (context, index) {
                    return _buildTamuCard(listTamu[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header Global dengan Logo Supabase
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
          Image.network(
            'https://dwyfjwwgrtdspgdaifyv.supabase.co/storage/v1/object/public/logo/logo.png',
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

  Widget _buildTitleBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
          ),
          const SizedBox(width: 16),
          const Text(
            'Buku Tamu',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN PILIH TANGGAL (Bisa di-copy ke halaman lain) ---
  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Ikon Kalender Biru
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFBBE1FA), // Biru pastel
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_today, color: Color(0xFF0D47A1), size: 20),
          ),
          const SizedBox(width: 12),
          // Teks Hari & Tanggal
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HARI INI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text('Senin, 24 Mei 2024', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          const Spacer(),
          // Tombol Pilih Tanggal (Dropdown)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                SizedBox(width: 6),
                Text('Pilih Tanggal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN SEARCH BAR & FILTER ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Masukkan nama tamu',
                  hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Color(0xFF0D47A1)), // Ikon Filter (Slider)
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN KARTU TAMU ---
  Widget _buildTamuCard(TamuData tamu) {
    bool isKeluar = tamu.status == 'Keluar';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200), // Border tipis
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tamu.nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 8),
              Text(
                'Masuk - ${tamu.jamMasuk} | Keluar - ${tamu.jamKeluar}',
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Badge Status (Masuk/Keluar)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isKeluar ? const Color(0xFFC8E6C9) : const Color(0xFFC5CAE9), // Hijau pastel / Biru pastel
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tamu.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isKeluar ? const Color(0xFF2E7D32) : const Color(0xFF283593), // Hijau gelap / Biru gelap
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('No.${tamu.noUrut}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}