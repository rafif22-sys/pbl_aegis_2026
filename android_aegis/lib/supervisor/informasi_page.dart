import 'package:flutter/material.dart';

// --- MODEL DATA PESAN ---
class PesanData {
  final String pengirim;
  final String tanggal;
  final String isi;
  final bool isSos;
  bool isUnread;
  bool isFavorit;

  PesanData({
    required this.pengirim,
    required this.tanggal,
    required this.isi,
    this.isSos = false,
    this.isUnread = false,
    this.isFavorit = false,
  });
}

class InformasiPage extends StatefulWidget {
  const InformasiPage({super.key});

  @override
  State<InformasiPage> createState() => _InformasiPageState();
}

class _InformasiPageState extends State<InformasiPage> {
  String _activeFilter = 'Semua';

  // --- DATA DUMMY SESUAI DESAIN ---
  final List<PesanData> daftarPesan = [
    PesanData(
      pengirim: 'Admin',
      tanggal: '16 Desember 2025 | 20.30',
      isi: 'Jadwal Shift selama seminggu sudah di perbaharui, silahkan cek dan selamat bertugas.',
      isUnread: true,
      isFavorit: false,
    ),
    PesanData(
      pengirim: 'AEGIS',
      tanggal: '16 Desember 2025 | 20.35',
      isi: 'Anda mendapat pesan SOS dari petugas Andi Suradi , mohon segera lakukan konfirmasi',
      isSos: true,
      isUnread: true,
      isFavorit: false,
    ),
    PesanData(
      pengirim: 'AEGIS',
      tanggal: '16 Desember 2025 | 20.35',
      isi: 'Terdapat kerusakan fasilitas di gerbang selatan perumahan, Silahkan klik disini untuk melihat laporan',
      isUnread: false,
      isFavorit: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Memfilter data berdasarkan tab yang aktif
    List<PesanData> pesanDitampilkan = _activeFilter == 'Semua' 
        ? daftarPesan 
        : daftarPesan.where((pesan) => pesan.isFavorit).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE4F0FB), // Biru muda Aegis
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopHeader(),
            const SizedBox(height: 20),
            _buildFilterTabs(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100), // Ruang bawah agar tidak tertutup tombol FAB
                itemCount: pesanDitampilkan.length,
                itemBuilder: (context, index) {
                  return _buildPesanCard(pesanDitampilkan[index]);
                },
              ),
            ),
          ],
        ),
      ),
      // --- FLOATING ACTION BUTTON (Tombol Kirim Pesan) ---
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 8),
        child: FloatingActionButton.extended(
          onPressed: () => _tampilkanDialogKirimPesan(context),
          backgroundColor: const Color(0xFF0D47A1), // Biru gelap
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          icon: const Icon(Icons.send_outlined, color: Colors.white, size: 20),
          label: const Text('Kirim Pesan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, color: Colors.lightBlueAccent, size: 24), // Fallback kalau internet mati
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

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTabButton('Semua'),
          const SizedBox(width: 12),
          _buildTabButton('Favorit'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    bool isActive = _activeFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0D47A1) : const Color(0xFFD2E3F4), // Biru gelap vs biru keputihan
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isActive ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildPesanCard(PesanData pesan) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(pesan.pengirim, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              if (pesan.isSos) ...[
                const SizedBox(width: 8),
                const Icon(Icons.warning, color: Color(0xFFD30000), size: 20), // Ikon SOS merah
              ],
              const Spacer(),
              Text(pesan.tanggal, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black45)),
              const SizedBox(width: 8),
              if (pesan.isUnread)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: Color(0xFFD30000), shape: BoxShape.circle),
                )
              else
                const SizedBox(width: 10), // Placeholder agar rata
            ],
          ),
          const SizedBox(height: 8),
          Text(pesan.isi, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  pesan.isFavorit = !pesan.isFavorit; // Toggle Favorit
                });
              },
              child: Icon(
                pesan.isFavorit ? Icons.star : Icons.star_border,
                color: pesan.isFavorit ? const Color(0xFFFFD700) : Colors.black87, // Kuning emas / Hitam
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI MENAMPILKAN DIALOG KIRIM PESAN ---
  void _tampilkanDialogKirimPesan(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4), // Efek gelap di belakang (blur)
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Kirim Pesan ke Petugas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 24),
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Masukan pesan untuk semua petugas',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0D47A1))),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol Batal
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD30000), // Merah
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    // Tombol Kirim
                    ElevatedButton.icon(
                      onPressed: () {
                        // Logika kirim pesan bisa ditaruh di sini nanti
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('Kirim', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1CAF5E), // Hijau
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}