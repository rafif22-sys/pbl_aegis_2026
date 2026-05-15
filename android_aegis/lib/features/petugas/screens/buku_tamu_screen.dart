import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadTamu();
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

  Future<void> _openKeluarDialog(TamuModel tamu) async {
    if (tamu.status == 'keluar') return;

    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: _KeluarTamuDialog(tamu: tamu),
      ),
    );

    if (result == true && mounted) {
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
    }
  }

  Future<void> _openDetailDialog(TamuModel tamu) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: _DetailTamuDialog(
          tamu: tamu,
          onKeluar: tamu.status == 'keluar'
              ? null
              : () async {
                  Navigator.pop(dialogContext);
                  await Future<void>.delayed(const Duration(milliseconds: 100));
                  if (mounted) {
                    await _openKeluarDialog(tamu);
                  }
                },
        ),
      ),
    );
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
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Row(
                    children: [
                      const Icon(Icons.arrow_back, size: 28),
                      const SizedBox(width: 10),
                      const Text(
                        'Buku Tamu',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _loadTamu,
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: 'Muat ulang',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDatePicker(),
                  const SizedBox(height: 15),
                  _buildSearchBar(),
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
                  else if (_tamus.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text(
                          'Belum ada data tamu.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._tamus.map(_guestCard),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        label: const Text(
          'Tambah Tamu',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: BukuTamuPage.kPrimary,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Masukkan nama tamu',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.tune, color: BukuTamuPage.kPrimary),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final now = DateTime.now();
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final months = [
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HARI INI',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.calendar_month, size: 16),
              Text(' Pilih Tanggal', style: TextStyle(fontSize: 12)),
              Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ),
      ],
    );
  }

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

class _DetailTamuDialog extends StatelessWidget {
  const _DetailTamuDialog({required this.tamu, this.onKeluar});

  final TamuModel tamu;
  final Future<void> Function()? onKeluar;

  @override
  Widget build(BuildContext context) {
    final fotoUrl = _resolveFotoUrl(tamu.fotoTamu);
    final waktuMasuk =
        '${_formatDate(tamu.waktuMasuk)} ${_formatTimeValue(tamu.waktuMasuk)}';
    final waktuKeluar = tamu.waktuKeluar != null
        ? '${_formatDate(tamu.waktuKeluar!)} ${_formatTimeValue(tamu.waktuKeluar!)}'
        : '-';
    final status = tamu.status == 'keluar' ? 'Keluar' : 'Masuk';
    final statusColor = tamu.status == 'keluar'
        ? const Color(0xFF2EB24F)
        : const Color(0xFF9EB7F8);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Informasi Tamu',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE85C5C),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 430;
                  final photo = _photoPreview(fotoUrl);
                  final info = _detailInfo(status, statusColor);

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [photo, const SizedBox(height: 16), info],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: photo),
                      const SizedBox(width: 16),
                      Expanded(flex: 5, child: info),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _timelineItem(
                      label: 'Masuk',
                      value: waktuMasuk,
                      color: const Color(0xFF2EB24F),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _timelineItem(
                      label: 'Keluar',
                      value: waktuKeluar,
                      color: const Color(0xFFE53935),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 160,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onKeluar == null ? null : () => onKeluar!(),
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
                    child: const Text(
                      'Tamu Keluar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoPreview(String? fotoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: AspectRatio(
        aspectRatio: 0.86,
        child: Container(
          color: const Color(0xFFF4F4F4),
          child: fotoUrl == null
              ? const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 42,
                    color: Colors.grey,
                  ),
                )
              : Image.network(
                  fotoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 42,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _detailInfo(String status, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor == const Color(0xFF2EB24F)
                    ? const Color(0xFF2EB24F)
                    : const Color(0xFF4766C4),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _infoRow(Icons.person, tamu.nama),
        _separator(),
        _infoRow(Icons.description_outlined, tamu.keperluan),
        _separator(),
        _infoRow(Icons.home_outlined, tamu.alamat),
        _separator(),
        _infoRow(Icons.badge_outlined, 'Petugas ${tamu.idUser}'),
      ],
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.black),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _separator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(color: Colors.black.withValues(alpha: 0.18), height: 1),
    );
  }

  Widget _timelineItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
    final now = DateTime.now();
    _jamCtrl = TextEditingController(text: now.hour.toString().padLeft(2, '0'));
    _menitCtrl = TextEditingController(
      text: now.minute.toString().padLeft(2, '0'),
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
