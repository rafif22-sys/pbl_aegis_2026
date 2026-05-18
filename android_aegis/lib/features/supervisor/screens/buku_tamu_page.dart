import 'package:flutter/material.dart';
import 'widgets/aegis_top_header.dart';

class TamuData {
  final String nama;
  final String jamMasuk;
  final String jamKeluar;
  final String status;
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
  final List<TamuData> listTamu = [
    TamuData(
      nama: 'Budi Prakoso',
      jamMasuk: '10:20',
      jamKeluar: '10:20',
      status: 'Keluar',
      noUrut: '111',
    ),
    TamuData(
      nama: 'Andi Surandi',
      jamMasuk: '10:20',
      jamKeluar: '-',
      status: 'Masuk',
      noUrut: '112',
    ),
    TamuData(
      nama: 'Budiono Simanjuntak',
      jamMasuk: '10:20',
      jamKeluar: '10:20',
      status: 'Keluar',
      noUrut: '111',
    ),
    TamuData(
      nama: 'Bambang Pamungkas',
      jamMasuk: '10:20',
      jamKeluar: '-',
      status: 'Masuk',
      noUrut: '112',
    ),
    TamuData(
      nama: 'Putra Surya',
      jamMasuk: '10:20',
      jamKeluar: '10:20',
      status: 'Keluar',
      noUrut: '111',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4F0FB),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Menggantikan fungsi manual lama dengan Reusable Widget resmi tim
            const AegisTopHeader(),

            _buildTitleBar(context),
            _buildDateFilter(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 20),

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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFBBE1FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Color(0xFF0D47A1),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HARI INI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Senin, 24 Mei 2024',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Spacer(),
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
                Text(
                  'Pilih Tanggal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
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
            child: const Icon(Icons.tune, color: Color(0xFF0D47A1)),
          ),
        ],
      ),
    );
  }

  Widget _buildTamuCard(TamuData tamu) {
    bool isKeluar = tamu.status == 'Keluar';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tamu.nama,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masuk - ${tamu.jamMasuk} | Keluar - ${tamu.jamKeluar}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isKeluar
                      ? const Color(0xFFC8E6C9)
                      : const Color(0xFFC5CAE9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tamu.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isKeluar
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF283593),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No.${tamu.noUrut}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
