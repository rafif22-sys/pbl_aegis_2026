import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/tamu_model.dart';
import '../providers/tamu_provider.dart';
import 'widgets/buku_tamu/formulir_tamu_screen.dart';
import 'widgets/buku_tamu/notification_screen.dart';
import 'widgets/buku_tamu/top_bar_screen.dart';

class BukuTamuPage extends StatefulWidget {
  const BukuTamuPage({super.key});

  static const Color kPrimary = Color(0xFF034DC0);
  static const Color kBg = Color(0xFFDCEFFE);

  @override
  State<BukuTamuPage> createState() => _BukuTamuPageState();
}

class _BukuTamuPageState extends State<BukuTamuPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<TamuModel> _tamus = const [];
  DateTime _selectedDate = DateTime.now();

  // ── State filter baru ─────────────────────────
  bool _showAllDates = false;        // true = tampilkan semua hari
  String _searchQuery = '';          // query pencarian nama
  String _filterStatus = 'semua';   // 'semua' | 'masuk' | 'keluar'
  final TextEditingController _searchCtrl = TextEditingController();

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  void initState() {
    super.initState();
    _loadTamu();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTamu() async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;

    if (token == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Sesi login tidak ditemukan.';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await context.read<TamuProvider>().fetchListTamu(token: token);

    if (!mounted) return;
    final tamuProvider = context.read<TamuProvider>();
    setState(() {
      _isLoading = false;
      if (tamuProvider.state == TamuListState.error) {
        _errorMessage = tamuProvider.errorMessage;
      } else {
        _tamus = tamuProvider.tamuList;
      }
    });
  }

  // ── Filter gabungan: tanggal + search + status ──
  List<TamuModel> get _filteredTamus {
    return _tamus.where((tamu) {
      // 1. Filter tanggal (skip jika showAllDates)
      if (!_showAllDates) {
        final masuk = tamu.waktuMasuk.toLocal();
        final matchDate = masuk.year == _selectedDate.year &&
            masuk.month == _selectedDate.month &&
            masuk.day == _selectedDate.day;
        if (!matchDate) return false;
      }

      // 2. Filter nama (search)
      if (_searchQuery.isNotEmpty) {
        final namaLower = tamu.nama.toLowerCase();
        if (!namaLower.contains(_searchQuery.toLowerCase())) return false;
      }

      // 3. Filter status
      if (_filterStatus != 'semua') {
        if (tamu.status != _filterStatus) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _openForm() async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: const FormulirTamuPage(),
        );
      },
    );

    if (result == true && mounted) {
      await _loadTamu();
      if (!mounted) return;
      NotificationScreen.show(
        context,
        message: 'Data tamu berhasil ditambahkan.',
        backgroundColor: const Color(0xFF0040A2),
        icon: Icons.check,
        iconColor: Colors.blue,
        iconBackgroundColor: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<bool> _prosesKeluar(TamuModel tamu) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return false;

    final result = await context.read<TamuProvider>().markKeluar(
      token: token,
      tamuId: tamu.id,
      waktuKeluar: DateTime.now(),
    );
    return result.success;
  }

  Future<void> _openDetailDialog(TamuModel tamu) async {
    final keluarBerhasil = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: _DetailTamuDialog(
          tamu: tamu,
          onKeluar: tamu.status == 'keluar'
              ? null
              : () => _prosesKeluar(tamu),
        ),
      ),
    );

    if (!mounted) return;

    if (keluarBerhasil == true) {
      await _loadTamu();
      if (!mounted) return;
      NotificationScreen.show(
        context,
        message: 'Berhasil mengubah status tamu.',
        backgroundColor: const Color(0xFF2EB24F),
        icon: Icons.check,
        iconColor: const Color(0xFF2EB24F),
        iconBackgroundColor: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else if (keluarBerhasil == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengubah status tamu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BukuTamuPage.kBg,
      body: Column(
        children: [
          const TopBarScreen(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadTamu,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 26, 16, 16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // ── Header: judul + toggle Semua/Hari Ini ──
                  Row(
                      children: [
                      GestureDetector(          // ← tambahkan di sini
                        onTap: () {
                          final role = context.read<AuthProvider>().user?.role;
                          final route = switch (role) {
                            'petugas'    => AppRoutes.petugasHome,
                            'supervisor' => AppRoutes.supervisorHome,
                            'warga'      => AppRoutes.wargaHome,
                            _            => AppRoutes.login,
                          };
                          Navigator.pushReplacementNamed(context, route);
                        },
                        child: const Icon(Icons.arrow_back, size: 28),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Buku Tamu',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      _buildAllDatesToggle(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDatePicker(),
                  const SizedBox(height: 15),
                  _buildSearchAndFilter(),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    )
                  else if (_filteredTamus.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.people_outline,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Tamu "$_searchQuery" tidak ditemukan.'
                                  : _showAllDates
                                      ? 'Belum ada data tamu.'
                                      : _isToday(_selectedDate)
                                          ? 'Belum ada tamu hari ini.'
                                          : 'Tidak ada tamu pada tanggal ini.',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._filteredTamus.map(_guestCard),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton.extended(
          onPressed: _openForm,
          label: const Text(
            'Tambah Tamu',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          backgroundColor: BukuTamuPage.kPrimary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ── Toggle Semua / Hari Ini (gantikan refresh button) ──
  Widget _buildAllDatesToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showAllDates = !_showAllDates),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _showAllDates ? BukuTamuPage.kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _showAllDates ? BukuTamuPage.kPrimary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _showAllDates ? Icons.calendar_view_month : Icons.today,
              size: 15,
              color: _showAllDates ? Colors.white : BukuTamuPage.kPrimary,
            ),
            const SizedBox(width: 5),
            Text(
              _showAllDates ? 'Semua Hari' : 'Hari Ini',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _showAllDates ? Colors.white : BukuTamuPage.kPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search bar + filter status dalam satu baris ──
  Widget _buildSearchAndFilter() {
    // Label untuk button berdasarkan status aktif
    final filterLabel = switch (_filterStatus) {
      'masuk' => 'Masuk',
      'keluar' => 'Keluar',
      _ => null,
    };
    final isFiltered = _filterStatus != 'semua';

    return Row(
      children: [
        // Search bar
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Masukkan nama tamu',
                hintStyle: const TextStyle(fontSize: 13),
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Tombol filter — ikon kecil dengan badge dot jika aktif
        PopupMenuButton<String>(
          onSelected: (val) => setState(() => _filterStatus = val),
          offset: const Offset(0, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (_) => [
            _popupItem('semua', 'Semua', Icons.people_outline, Colors.grey),
            _popupItem('masuk', 'Masuk', Icons.login, const Color(0xFF034DC0)),
            _popupItem('keluar', 'Keluar', Icons.logout, const Color(0xFF2EB24F)),
          ],
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isFiltered
                      ? BukuTamuPage.kPrimary.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isFiltered
                        ? BukuTamuPage.kPrimary
                        : Colors.grey.shade300,
                  ),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: isFiltered ? BukuTamuPage.kPrimary : Colors.grey,
                ),
              ),
              // Badge dot merah kecil jika ada filter aktif
              if (isFiltered)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

PopupMenuItem<String> _popupItem(
    String value, String label, IconData icon, Color color) {
  final isSelected = _filterStatus == value;
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: 16, color: isSelected ? color : Colors.grey),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : Colors.black87,
          ),
        ),
        if (isSelected) ...[
          const Spacer(),
          Icon(Icons.check, size: 14, color: color),
        ],
      ],
    ),
  );
}

  // ── Date picker (tombol "Semua" dihapus dari sini karena sudah pindah ke header) ──
  Widget _buildDatePicker() {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    final days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFBBDEFB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.calendar_today, color: BukuTamuPage.kPrimary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _showAllDates
                    ? 'SEMUA HARI'
                    : isToday
                        ? 'HARI INI'
                        : 'TANGGAL DIPILIH',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                _showAllDates
                    ? 'Semua Data Tamu'
                    : '${days[_selectedDate.weekday - 1]}, '
                        '${_selectedDate.day} '
                        '${months[_selectedDate.month - 1]} '
                        '${_selectedDate.year}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Tombol Pilih Tanggal — disable saat mode Semua Hari
        GestureDetector(
          onTap: _showAllDates
              ? null
              : () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    locale: const Locale('id', 'ID'),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _showAllDates ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 16,
                  color: _showAllDates ? Colors.grey : Colors.black87,
                ),
                Text(
                  ' Pilih Tanggal',
                  style: TextStyle(
                    fontSize: 12,
                    color: _showAllDates ? Colors.grey : Colors.black87,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: _showAllDates ? Colors.grey : Colors.black87,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ... _guestCard, _formatTime tetap sama seperti sebelumnya
  Widget _guestCard(TamuModel tamu) {
    final waktuMasuk = _formatTime(tamu.waktuMasuk);
    final waktuKeluar = tamu.waktuKeluar != null
        ? _formatTime(tamu.waktuKeluar!)
        : '--:--';
    final isKeluar = tamu.status == 'keluar';

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _openDetailDialog(tamu),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tamu.nama,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isKeluar
                            ? const Color(0xFFC8E6C9)
                            : const Color(0xFFBBDEFB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isKeluar ? 'Keluar' : 'Masuk',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Masuk $waktuMasuk | Keluar $waktuKeluar',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '#${tamu.id.toString().padLeft(3, '0')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DetailTamuDialog: StatelessWidget → StatefulWidget
// Desain 100% sama, hanya tambah _isProcessing untuk handle loading di tombol
// ─────────────────────────────────────────────────────────────────────────────

class _DetailTamuDialog extends StatefulWidget {
  const _DetailTamuDialog({required this.tamu, this.onKeluar});

  final TamuModel tamu;
  final Future<bool> Function()? onKeluar;

  @override
  State<_DetailTamuDialog> createState() => _DetailTamuDialogState();
}

class _DetailTamuDialogState extends State<_DetailTamuDialog> {
  bool _isProcessing = false;

  Future<void> _handleKeluar() async {
    if (_isProcessing || widget.onKeluar == null) return;
    setState(() => _isProcessing = true);
    try {
      final berhasil = await widget.onKeluar!();
      if (!mounted) return;
      Navigator.pop(context, berhasil);
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotoUrl = _resolveFotoUrl(widget.tamu.fotoTamu);
    final waktuMasuk = _formatTimeValue(widget.tamu.waktuMasuk);
    final waktuKeluarStr = widget.tamu.waktuKeluar != null
        ? _formatTimeValue(widget.tamu.waktuKeluar!)
        : '-';
    final isKeluar = widget.tamu.status == 'keluar';
    final status = isKeluar ? 'Keluar' : 'Masuk';

    final statusBgColor = isKeluar
        ? const Color(0xFFC8E6C9)
        : const Color(0xFFBBDEFB);
    final statusTextColor = isKeluar
        ? const Color(0xFF2EB24F)
        : const Color(0xFF034DC0);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ── Header ──────────────────────────────
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Informasi Tamu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: _isProcessing ? null : () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE85C5C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Foto BESAR (kiri) + Info (kanan) ────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ── FOTO: lebih lebar & mengisi tinggi penuh ──
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 150, // lebar lebih besar
                      child: fotoUrl == null
                          ? Container(
                              color: const Color(0xFFF0F0F0),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 44,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Image.network(
                              fotoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFF0F0F0),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 44,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ── Kolom kanan: badge oval BESAR + info rows ──
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Badge status OVAL penuh lebar
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(50), // <-- oval/pill
                          ),
                          child: Text(
                            status,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: statusTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        _infoRow(Icons.person, widget.tamu.nama),
                        const SizedBox(height: 6),
                        _infoRow(Icons.description_outlined, widget.tamu.keperluan),
                        const SizedBox(height: 6),
                        _infoRow(Icons.home_outlined, widget.tamu.alamat),
                        const SizedBox(height: 6),
                        _infoRow(Icons.badge_outlined, widget.tamu.namaUser),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 8),

            // ── Waktu + Tombol ───────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _timelineItem(
                        label: 'Masuk',
                        value: waktuMasuk,
                        color: const Color(0xFF2EB24F),
                      ),
                      const SizedBox(height: 6),
                      _timelineItem(
                        label: 'Keluar',
                        value: waktuKeluarStr,
                        color: const Color(0xFFE53935),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: (isKeluar || _isProcessing) ? null : _handleKeluar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2EB24F),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFBFE8C8),
                      disabledForegroundColor: Colors.white70,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Tamu Keluar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.black54),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _timelineItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(Icons.access_time, color: color, size: 16),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13, color: Colors.black),
            children: [
              TextSpan(
                text: '$label  ',
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KeluarTamuDialog extends StatefulWidget {
  const _KeluarTamuDialog({required this.tamu});

  final TamuModel tamu;

  @override
  State<_KeluarTamuDialog> createState() => _KeluarTamuDialogState();
}

class _KeluarTamuDialogState extends State<_KeluarTamuDialog> {
  late final TextEditingController _jamCtrl;
  late final TextEditingController _menitCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final waktu = (widget.tamu.status == 'masuk' && widget.tamu.waktuKeluar != null)
        ? widget.tamu.waktuKeluar!
        : DateTime.now();

    _jamCtrl = TextEditingController(
      text: waktu.hour.toString().padLeft(2, '0'),
    );
    _menitCtrl = TextEditingController(
      text: waktu.minute.toString().padLeft(2, '0'),
    );
  }

  @override
  void dispose() {
    _jamCtrl.dispose();
    _menitCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpanKeluar() async {
    if (_isSaving) return;

    final auth = context.read<AuthProvider>();
    final token = auth.token;

    if (token == null) {
      _showMessage('Sesi login tidak ditemukan.');
      return;
    }

    final jam = int.tryParse(_jamCtrl.text.trim());
    final menit = int.tryParse(_menitCtrl.text.trim());

    if (jam == null ||
        menit == null ||
        jam < 0 ||
        jam > 23 ||
        menit < 0 ||
        menit > 59) {
      _showMessage('Jam keluar tidak valid.');
      return;
    }

    final now = DateTime.now();
    final waktuKeluar = DateTime(now.year, now.month, now.day, jam, menit);

    setState(() => _isSaving = true);
    try {
      final result = await context.read<TamuProvider>().markKeluar(
        token: token,
        tamuId: widget.tamu.id,
        waktuKeluar: waktuKeluar,
      );

      if (!result.success) {
        throw Exception(result.message);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.tamu.nama,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Text(
            widget.tamu.keperluan,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          const Text(
            'Jam Keluar',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _timeField(controller: _jamCtrl, hint: 'HH'),
              ),
              const SizedBox(width: 10),
              const Text(
                ':',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _timeField(controller: _menitCtrl, hint: 'MM'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _simpanKeluar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2EB24F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(_isSaving ? 'Menyimpan...' : 'Tamu Keluar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 2,
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

String? _resolveFotoUrl(String? fotoTamu) {
  if (fotoTamu == null || fotoTamu.trim().isEmpty) return null;
  if (fotoTamu.startsWith('http://') || fotoTamu.startsWith('https://')) {
    return fotoTamu;
  }

  const supabaseStorageUrl =
      'https://dwyfjwwgrtdspgdaifyv.supabase.co/storage/v1/object/public/aegis/';

  final cleaned = fotoTamu.startsWith('/') ? fotoTamu.substring(1) : fotoTamu;
  return '$supabaseStorageUrl$cleaned';
}

String _formatTimeValue(DateTime dateTime) {
  final hh = dateTime.hour.toString().padLeft(2, '0');
  final mm = dateTime.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String _formatDate(DateTime dateTime) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
}