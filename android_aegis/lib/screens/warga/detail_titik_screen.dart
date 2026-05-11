import 'package:flutter/material.dart';

class DetailTitikScreen extends StatefulWidget {
  const DetailTitikScreen({super.key});

  @override
  State<DetailTitikScreen> createState() => _DetailTitikScreenState();
}

class _DetailTitikScreenState extends State<DetailTitikScreen> {
  final List<Map<String, dynamic>> _titikList = [
    {
      'nama': 'Titik 1',
      'waktu': '07.30',
      'kondisi': 'Aman',
      'catatan': 'Keadaan aman dan gembok terpasang',
      'imageUrl': '',
    },
    {
      'nama': 'Titik 2',
      'waktu': '07.45',
      'kondisi': 'Aman',
      'catatan': 'Tidak ada masalah',
      'imageUrl': '',
    },
    {
      'nama': 'Titik 3',
      'waktu': '08.00',
      'kondisi': 'Ada Isu',
      'catatan': 'Temuan lampu jalan mati',
      'imageUrl': '',
    },
    {
      'nama': 'Titik 4',
      'waktu': '08.15',
      'kondisi': 'Aman',
      'catatan': 'Kondisi normal',
      'imageUrl': '',
    },
    {
      'nama': 'Titik 5',
      'waktu': '08.30',
      'kondisi': 'Aman',
      'catatan': 'Area parkir aman',
      'imageUrl': '',
    },
  ];

  void _showPhotoModal(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PhotoModal(
        titikName: _titikList[index]['nama'],
        photoIndex: index + 1,
        totalPhotos: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe3f2fd),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Petugas',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0d47a1),
                        ),
                      ),
                      Text(
                        'Budi Santoso',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Peta Lokasi Patroli',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _titikList.length,
                itemBuilder: (context, index) {
                  final titik = _titikList[index];
                  return _TitikCard(
                    nama: titik['nama'],
                    waktu: titik['waktu'],
                    kondisi: titik['kondisi'],
                    catatan: titik['catatan'],
                    onTapPhoto: () => _showPhotoModal(context, index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitikCard extends StatelessWidget {
  final String nama;
  final String waktu;
  final String kondisi;
  final String catatan;
  final VoidCallback onTapPhoto;

  const _TitikCard({
    required this.nama,
    required this.waktu,
    required this.kondisi,
    required this.catatan,
    required this.onTapPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Waktu: $waktu',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'Kondisi: ',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      kondisi,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kondisi == 'Aman'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Catatan: $catatan',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onTapPhoto,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.photo, color: Colors.white, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoModal extends StatelessWidget {
  final String titikName;
  final int photoIndex;
  final int totalPhotos;

  const _PhotoModal({
    required this.titikName,
    required this.photoIndex,
    required this.totalPhotos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                const SizedBox(width: 8),
                Text(
                  'Foto Laporan - $titikName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.image, size: 64, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chevron_left, size: 32),
                const SizedBox(width: 20),
                Text(
                  '$photoIndex',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.chevron_right, size: 32),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
