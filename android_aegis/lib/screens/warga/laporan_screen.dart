import 'package:flutter/material.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  int _selectedShift = 0;
  
  final List<Map<String, dynamic>> _dummyReports = [
    {'status': 'Aman', 'name': 'Budi Santoso', 'time': '07.00 - 09.00', 'checkpoints': 5},
    {'status': 'Ada Isu', 'name': 'Andi Pratama', 'time': '09.00 - 11.00', 'checkpoints': 4},
    {'status': 'Aman', 'name': 'Rudi Hermawan', 'time': '11.00 - 13.00', 'checkpoints': 6},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe3f2fd),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                    'Laporan Harian',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Jumat, 14 April 2026',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF102a43),
                ),
              ),
              const SizedBox(height: 20),
              _buildStatsGrid(),
              const SizedBox(height: 20),
              _buildShiftTabs(),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _dummyReports.length,
                  itemBuilder: (context, index) {
                    final report = _dummyReports[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _OfficerCard(
                        status: report['status'],
                        isAman: report['status'] == 'Aman',
                        checkpointCount: report['checkpoints'],
                        name: report['name'],
                        time: report['time'],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.5,
        children: [
          _statCard(
            '10',
            'Total Patroli',
            const Color(0xFFe3f2fd),
            Icons.check_box_outlined,
          ),
          _statCard(
            '24',
            'Total Checkpoint',
            const Color(0xFFd1e7dd),
            Icons.location_on,
          ),
          _statCard(
            '24',
            'Petugas',
            const Color(0xFFe0e0f8),
            Icons.person_outline,
          ),
          _statCard(
            '24',
            'Isu',
            const Color(0xFFf8d7da),
            Icons.error_outline,
          ),
        ],
      ),
    );
  }

  Widget _statCard(String number, String label, Color bgColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Icon(icon, size: 20, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftTabs() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isSelected = _selectedShift == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedShift = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Shift ${index + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _OfficerCard extends StatelessWidget {
  final String status;
  final bool isAman;
  final int checkpointCount;
  final String name;
  final String time;

  const _OfficerCard({
    required this.status,
    required this.isAman,
    required this.checkpointCount,
    required this.name,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isAman ? const Color(0xFF4caf50) : const Color(0xFFd32f2f),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$checkpointCount Checkpoint',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 15),
                Text(
                  'Petugas: $name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Waktu: $time',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/detail-titik');
                  },
                  child: const Row(
                    children: [
                      Text(
                        'Detail',
                        style: TextStyle(
                          color: Color(0xFF2196f3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.description_outlined,
                          color: Color(0xFF2196f3), size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
