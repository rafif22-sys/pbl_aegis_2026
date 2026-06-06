// lib/features/petugas/screens/sesi_patroli_screen.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/patroli_model.dart';
import '../repositories/patroli_repository.dart';
import 'sos_form_screen.dart';

// ─────────────────────────────────────────────────────────
// Konstanta warna
// ─────────────────────────────────────────────────────────
class _C {
  static const bgPage    = Color(0xFFDCEFFE);
  static const blue      = Color(0xFF1565C0);
  static const blueCard  = Color(0xFF0040A2);  // header sesi patroli
  static const blueDark  = Color(0xFF0F2A44);
  static const iconBg    = Color(0xFFC6DDF4);
  static const muted     = Color(0xFF64748B);
  static const gray      = Color(0xFF94A3B8);
  static const green     = Color(0xFF22C55E);
  static const header    = Color(0xFF0F172A);
  static const cardBg    = Colors.white;

  static const logoUrl =
      'https://dwyfjwwgrtdspgdaifyv.supabase.co/storage/v1/object/public/logo/new_logo.png';
}

// ─────────────────────────────────────────────────────────
// OSRM routing
// ─────────────────────────────────────────────────────────
Future<List<LatLng>> fetchOsrmRoute(List<LatLng> waypoints) async {
  if (waypoints.length < 2) return waypoints;
  final coords = waypoints.map((p) => '${p.longitude},${p.latitude}').join(';');
  final url = Uri.parse(
    'https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson',
  );
  try {
    final res = await http.get(url).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return waypoints;
    final body  = jsonDecode(res.body);
    final route = body['routes']?[0];
    if (route == null) return waypoints;
    final coords2 = route['geometry']['coordinates'] as List;
    return coords2
        .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
        .toList();
  } catch (_) {
    return waypoints;
  }
}

// ─────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────
class SesiPatroliScreen extends StatefulWidget {
  final int idJadwalAbsensi;
  const SesiPatroliScreen({super.key, required this.idJadwalAbsensi});

  @override
  State<SesiPatroliScreen> createState() => _SesiPatroliScreenState();
}

class _SesiPatroliScreenState extends State<SesiPatroliScreen> {
  final _repo    = PatroliRepository();
  final _mapCtrl = MapController();

  PatroliModel? _sesi;
  bool          _loading      = true;
  String?       _error;
  LatLng?       _myPos;
  Timer?        _lokasiTimer;
  List<LatLng>  _routePoints  = [];
  bool          _loadingRoute = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _lokasiTimer?.cancel();
    super.dispose();
  }

  String get _token => context.read<AuthProvider>().token ?? '';

  Future<void> _init() async {
    await _loadSesi();
    await _startTracking();
  }

  Future<void> _loadSesi() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _repo.getSesi(
        token: _token,
        idJadwalAbsensi: widget.idJadwalAbsensi,
      );
      setState(() => _sesi = data);

      if (data.checkpoints.length >= 2) {
        setState(() => _loadingRoute = true);
        final waypoints = data.checkpoints
            .map((cp) => LatLng(cp.latitude, cp.longitude))
            .toList();
        final route = await fetchOsrmRoute(waypoints);
        if (mounted) setState(() { _routePoints = route; _loadingRoute = false; });
      }

      if (data.checkpoints.isNotEmpty) {
        final cp = data.checkpoints.first;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _mapCtrl.move(LatLng(cp.latitude, cp.longitude), 15);
        });
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startTracking() async {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) return;
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) setState(() => _myPos = LatLng(pos.latitude, pos.longitude));
    } catch (_) {}

    _lokasiTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        if (!mounted) return;
        setState(() => _myPos = LatLng(pos.latitude, pos.longitude));
        await _repo.updateLokasi(
          token: _token,
          idJadwalAbsensi: widget.idJadwalAbsensi,
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
      } catch (_) {}
    });
  }

  void _flyToMe() {
    if (_myPos != null) _mapCtrl.move(_myPos!, 16);
  }

  void _buatLaporan(CheckpointPatroli cp) {
    // TODO: Navigator.push ke BuatLaporanScreen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Buat laporan: ${cp.namaCheckpoint}'),
        backgroundColor: _C.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bgPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Back button row (tanpa refresh) ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: _C.blueDark, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'SESI PATROLI',
                    style: TextStyle(
                      color: _C.blueDark, fontSize: 20,
                      fontWeight: FontWeight.bold, letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Card putih pembungkus seluruh konten ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.08),
                        blurRadius: 20, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(color: _C.blue))
                        : _error != null
                            ? _buildError()
                            : _sesi == null
                                ? const SizedBox()
                                : _buildBody(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Body ─────────────────────────────────────────────
  Widget _buildBody() {
    final sesi    = _sesi!;
    final selesai = sesi.checkpoints.where((c) => c.sudahDilaporkan).length;
    final total   = sesi.checkpoints.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Card (Figma: biru gelap, nomor sesi + shift + jam) ──
          _buildSesiHeaderCard(sesi),
          const SizedBox(height: 16),

          // ── Peta (tanpa card wrapper — langsung rounded) ──
          _buildMapSection(sesi),
          const SizedBox(height: 20),

          // ── Daftar Patroli ──
          _buildCheckpointSection(sesi),
          const SizedBox(height: 16),

          // ── Tombol Kirim ──
          _buildKirimButton(sesi),
          const SizedBox(height: 12),

          // ── Tombol SOS ──
          _buildSOSButton(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Header Card — sesuai Figma:
  //   - Background biru gelap (#0F2A44)
  //   - Kiri: icon shield bulat + "Sesi Patroli" bold + namaRute
  // ─────────────────────────────────────────────────────
  Widget _buildSesiHeaderCard(PatroliModel sesi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _C.blueCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _C.blueCard.withOpacity(0.25),
            blurRadius: 10, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Shield icon bulat (sesuai Figma)
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Judul + nama rute
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sesi Patroli',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sesi.jamShift.isNotEmpty ? sesi.jamShift : sesi.namaRute,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Peta — sesuai Figma: rounded card putih
  //   - Marker angka biru, done = hijau centang
  //   - Garis rute biru solid
  //   - Tombol lokasi di pojok kanan bawah
  // ─────────────────────────────────────────────────────
  Widget _buildMapSection(PatroliModel sesi) {
    final routeToShow = _routePoints.isNotEmpty
        ? _routePoints
        : sesi.checkpoints.map((cp) => LatLng(cp.latitude, cp.longitude)).toList();

    final center = sesi.checkpoints.isNotEmpty
        ? LatLng(sesi.checkpoints.first.latitude, sesi.checkpoints.first.longitude)
        : const LatLng(-7.05, 110.437);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 260,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapCtrl,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.aegis.app',
                  ),
                  if (routeToShow.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routeToShow,
                          strokeWidth: 6,
                          color: _C.blue.withOpacity(0.22),
                        ),
                        Polyline(
                          points: routeToShow,
                          strokeWidth: 3.5,
                          color: _C.blue,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      ...sesi.checkpoints.map(_buildCheckpointMarker),
                      if (_myPos != null)
                        Marker(
                          point: _myPos!,
                          width: 48, height: 48,
                          child: _MyLocationDot(),
                        ),
                    ],
                  ),
                ],
              ),

              // Loading overlay
              if (_loadingRoute)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _C.blue),
                    ),
                  ),
                ),

              // Tombol lokasi saya — pojok kanan bawah
              Positioned(
                bottom: 12, right: 12,
                child: GestureDetector(
                  onTap: _flyToMe,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8, offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.my_location_rounded,
                        color: _C.blue, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Marker _buildCheckpointMarker(CheckpointPatroli cp) {
    final done = cp.sudahDilaporkan;
    return Marker(
      point: LatLng(cp.latitude, cp.longitude),
      width: 42, height: 52,
      child: GestureDetector(
        onTap: () => _mapCtrl.move(LatLng(cp.latitude, cp.longitude), 17),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: done ? _C.green : _C.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: (done ? _C.green : _C.blue).withOpacity(0.4),
                    blurRadius: 8, offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : Text(
                        '${cp.urutan}',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            Container(width: 3, height: 7,
                color: done ? _C.green : _C.blue),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Daftar Patroli — sesuai Figma:
  //   - Judul "Daftar Patroli" bold hitam
  //   - Setiap item: [checkbox kotak] [nomor bulat biru] [nama] [tombol]
  //   - Tombol "Buat Laporan": abu-abu pill, icon dokumen
  //   - Done: tombol hilang, checkbox tercentang hijau
  // ─────────────────────────────────────────────────────
  Widget _buildCheckpointSection(PatroliModel sesi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Patroli',
          style: TextStyle(
            color: _C.blueDark,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...sesi.checkpoints.map((cp) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildCheckpointTile(cp),
        )),
      ],
    );
  }

  Widget _buildCheckpointTile(CheckpointPatroli cp) {
    final done = cp.sudahDilaporkan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.06),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Checkbox kotak (sesuai Figma) ──
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: done ? _C.green : Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: done ? _C.green : const Color(0xFFCBD5E1),
                width: 1.8,
              ),
            ),
            child: done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 10),

          // ── Nomor bulat biru ──
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(
              color: _C.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${cp.urutan}',
                style: const TextStyle(
                  color: Colors.white, fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Nama checkpoint ──
          Expanded(
            child: Text(
              cp.namaCheckpoint,
              style: const TextStyle(
                color: _C.blueDark, fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ── Tombol aksi ──
          done
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_rounded,
                          color: Color(0xFF166534), size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Selesai',
                        style: TextStyle(
                          color: Color(0xFF166634), fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : GestureDetector(
                  onTap: () => _buatLaporan(cp),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      // Abu-abu sesuai Figma (belum done)
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_rounded,
                            color: Color(0xFF64748B), size: 13),
                        SizedBox(width: 5),
                        Text(
                          'Buat Laporan',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Tombol Kirim — pill abu-abu penuh (sesuai Figma)
  //   aktif → biru, disabled → abu
  // ─────────────────────────────────────────────────────
  Widget _buildKirimButton(PatroliModel sesi) {
    final selesai = sesi.checkpoints.where((c) => c.sudahDilaporkan).length;
    final total   = sesi.checkpoints.length;
    final allDone = selesai == total && total > 0;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: allDone ? () {
          // TODO: aksi kirim laporan final
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: allDone ? _C.blue : const Color(0xFFCBD5E1),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFCBD5E1),
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26)),
          elevation: allDone ? 2 : 0,
        ),
        child: Text(
          allDone ? 'Kirim Laporan' : 'Kirim Laporan',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  
  Widget _buildSOSButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SOSFormScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          // Outer ring pink (sama dengan home)
          color: const Color(0xFFF09FA6).withOpacity(0.45),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFED4D5C), Color(0xFFF27855)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'KIRIM SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(width: 12),
              // Shield icon bulat — sama persis dengan home
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(Icons.shield_outlined,
                      size: 26, color: Colors.white),
                  const Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 7,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 52, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadSesi,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.blue, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Dot lokasi saya (pulse animation)
// ─────────────────────────────────────────────────────────
class _MyLocationDot extends StatefulWidget {
  @override
  State<_MyLocationDot> createState() => _MyLocationDotState();
}

class _MyLocationDotState extends State<_MyLocationDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _scale,
          builder: (_, __) => Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Container(
          width: 18, height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.5),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}