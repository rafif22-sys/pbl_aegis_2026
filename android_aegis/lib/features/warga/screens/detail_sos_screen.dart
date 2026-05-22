import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../sos/models/sos_model.dart';
import '../../petugas/screens/widgets/detail_sos/sos_detail_header.dart';
import '../../petugas/screens/widgets/detail_sos/sos_detail_map.dart';
import '../../petugas/screens/widgets/detail_sos/sos_detail_pengirim_card.dart';
import '../../petugas/screens/widgets/detail_sos/sos_detail_deskripsi_card.dart';
import '../../petugas/screens/widgets/detail_sos/sos_konfirmasi_button.dart';

class DetailSosScreen extends StatefulWidget {
  final SosModel sos;
  const DetailSosScreen({super.key, required this.sos});

  @override
  State<DetailSosScreen> createState() => _DetailSosScreenState();
}

class _DetailSosScreenState extends State<DetailSosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  Color get _statusColor => widget.sos.status == StatusSOS.selesai
      ? const Color(0xFF1A3FA0)
      : const Color(0xFFD30000);

  IconData get _jenisIcon {
    switch (widget.sos.jenisKeadaan) {
      case JenisKeadaan.kebakaran:   return Icons.local_fire_department;
      case JenisKeadaan.pencurian:   return Icons.person_off;
      case JenisKeadaan.hewanLiar:   return Icons.pets;
      case JenisKeadaan.bencanaAlam: return Icons.thunderstorm;
      case JenisKeadaan.lainnya:     return Icons.warning_amber_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.82, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatWaktu(String raw) {
    try {
      final dt    = DateTime.parse(raw).toLocal();
      const bulan = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei',
        'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${bulan[dt.month]}, '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCEFFE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.black87, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'PESAN SOS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  children: [
                    SosDetailHeader(sos: widget.sos, statusColor: _statusColor),
                    SosDetailMap(
                      center:      LatLng(widget.sos.latitude, widget.sos.longitude),
                      statusColor: _statusColor,
                      jenisIcon:   _jenisIcon,
                      pulseAnim:   _pulseAnim,
                    ),
                    const SizedBox(height: 16),
                    SosDetailPengirimCard(
                      sos:            widget.sos,
                      waktuFormatted: _formatWaktu(widget.sos.waktuKirim),
                    ),
                    const SizedBox(height: 12),
                    SosDetailDeskripsiCard(
                      sos:         widget.sos,
                      statusColor: _statusColor,
                    ),
                    const SizedBox(height: 12),
                    SosKonfirmasiButton(
                      sos:          widget.sos,
                      isLoading:    false,
                      onKonfirmasi: () {},
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
}
