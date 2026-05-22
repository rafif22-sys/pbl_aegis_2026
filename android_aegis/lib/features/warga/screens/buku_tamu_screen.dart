import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/buku_tamu_service.dart';
import '../models/buku_tamu_model.dart';

class BukuTamuScreen extends StatefulWidget {
  const BukuTamuScreen({super.key});

  @override
  State<BukuTamuScreen> createState() => _BukuTamuScreenState();
}

class _BukuTamuScreenState extends State<BukuTamuScreen> {
  final _service = BukuTamuService();
  final _searchController = TextEditingController();
  List<BukuTamuModel> _data = [];
  List<BukuTamuModel> _filtered = [];
  bool _isLoading = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterLocal);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final token = context.read<AuthProvider>().token!;
      final tanggal = _selectedDate != null
          ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
          : null;
      _data = await _service.getBukuTamu(token: token, tanggal: tanggal);
      _filterLocal();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat buku tamu')),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _filterLocal() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered =
          _data.where((t) => t.nama.toLowerCase().contains(query)).toList();
    });
  }

  void _showDatePickerBottomSheet() {
    DateTime tempDate = _selectedDate ?? DateTime.now();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Text('Pilih Tanggal',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  CalendarDatePicker(
                    initialDate: tempDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    onDateChanged: (d) => setModalState(() => tempDate = d),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          setState(() => _selectedDate = tempDate);
                          Navigator.pop(context);
                          _fetchData();
                        },
                        child: const Text('Tampilkan',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4F0FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filtered.isEmpty
                        ? const Center(
                            child: Text('Belum ada data tamu',
                                style: TextStyle(color: Colors.black45)))
                        : ListView.builder(
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) =>
                                _buildTamuCard(_filtered[index]),
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
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Image.network(
            'https://dwyfjwwgrtdspgdaifyv.supabase.co/storage/v1/object/public/logo/new_logo.png',
            height: 24,
            width: 24,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.pets, color: Colors.lightBlueAccent, size: 24),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'ADVANCED EMERGENCY & GUARD INFORMATION SYSTEM',
              style: TextStyle(
                  color: Colors.white70, fontSize: 10, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
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
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
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
            child: const Icon(Icons.calendar_today,
                color: Color(0xFF0D47A1), size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HARI INI',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              Text('Senin, 24 Mei 2024',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showDatePickerBottomSheet,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                  SizedBox(width: 6),
                  Text('Pilih Tanggal',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down,
                      size: 16, color: Colors.black54),
                ],
              ),
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
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama tamu',
                  hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _showDatePickerBottomSheet,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune, color: Color(0xFF0D47A1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTamuCard(BukuTamuModel tamu) {
    bool isKeluar = tamu.status.toLowerCase() == 'keluar';
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
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tamu.nama,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 8),
              Text(
                'Masuk - ${tamu.jamMasuk} | Keluar - ${tamu.jamKeluar ?? "-"}',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              Text('No.${tamu.noAntrian}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}
