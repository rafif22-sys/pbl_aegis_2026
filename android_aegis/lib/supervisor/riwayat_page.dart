import 'package:flutter/material.dart';
import 'detail_sos_page.dart'; // Import halaman detail

// --- KELAS DATA DUMMY SOS ---
class SosData {
  final String date;
  final String time;
  final String status;
  final String name;
  final String imgUrl;

  SosData({required this.date, required this.time, required this.status, required this.name, required this.imgUrl});
}

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  // Data Dummy sesuai desain
  final List<SosData> listSos = [
    SosData(date: 'Oct 24, 2023, Selasa', time: '14:30', status: 'MENUNGGU BANTUAN', name: 'Andika Pratama', imgUrl: 'https://randomuser.me/api/portraits/men/32.jpg'),
    SosData(date: 'Oct 24, 2023, Selasa', time: '11:15', status: 'SELESAI', name: 'Budi Santoso', imgUrl: 'https://randomuser.me/api/portraits/men/44.jpg'),
    SosData(date: 'Oct 23, 2023, Senin', time: '23:05', status: 'SELESAI', name: 'Dian Wijaya', imgUrl: 'https://randomuser.me/api/portraits/men/62.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4F0FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text('SINYAL SOS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCards(),
                    const SizedBox(height: 32),
                    
                    // Judul Daftar SOS & Filter
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Daftar SOS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFF0D47A1), borderRadius: BorderRadius.circular(20)),
                            child: const Row(
                              children: [
                                Text('Terbaru', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                SizedBox(width: 4),
                                Icon(Icons.filter_list, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // List Kartu SOS
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listSos.length,
                      itemBuilder: (context, index) {
                        return _buildSosCard(listSos[index]);
                      },
                    ),
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

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: const Border(left: BorderSide(color: Color(0xFF0D47A1), width: 4)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pesan SOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('124', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      Icon(Icons.bar_chart, color: Colors.blue.shade300),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: const Border(left: BorderSide(color: Colors.green, width: 4)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SOS Dikonfirmasi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('118', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                      const Icon(Icons.check_circle_outline, color: Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosCard(SosData data) {
    bool isMenunggu = data.status == 'MENUNGGU BANTUAN';
    
    return GestureDetector(
      onTap: () {
        // Navigasi ke Detail SOS
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailSosPage(
              nama: data.name,
              waktu: '${data.date.split(',')[0]}, ${data.time}',
              initialStatus: data.status,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data.date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isMenunggu ? const Color(0xFFFFE5E5) : const Color(0xFFE4F1FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isMenunggu ? Colors.red.shade200 : Colors.blue.shade200),
                  ),
                  child: Text(
                    data.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isMenunggu ? const Color(0xFFD30000) : const Color(0xFF1976D2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(data.time, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(data.imgUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(data.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isMenunggu ? const Color(0xFF0D47A1) : Colors.grey.shade200,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isMenunggu ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}