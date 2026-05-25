import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../../auth/providers/auth_provider.dart';
import '../../../providers/tamu_provider.dart';
import 'upload_foto_screen.dart';

class FormulirTamuPage extends StatefulWidget {
  const FormulirTamuPage({super.key});

  @override
  State<FormulirTamuPage> createState() => _FormulirTamuPageState();
}

class _FormulirTamuPageState extends State<FormulirTamuPage> {
  final _namaCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _keperluanCtrl = TextEditingController();
  final _jamH = TextEditingController();
  final _jamM = TextEditingController();
  XFile? _fotoTamu;
  bool _isSaving = false;

  String? _namaError;
  String? _alamatError;
  String? _keperluanError;
  String? _jamError;
  bool _fotoError = false;

  bool get _isFormReady =>
      _namaCtrl.text.trim().isNotEmpty &&
      _alamatCtrl.text.trim().isNotEmpty &&
      _keperluanCtrl.text.trim().isNotEmpty &&
      _fotoTamu != null;

  @override
  void initState() {
    super.initState();
    _namaCtrl.addListener(() => setState(() {}));
    _alamatCtrl.addListener(() => setState(() {}));
    _keperluanCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    _keperluanCtrl.dispose();
    _jamH.dispose();
    _jamM.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _namaError = _namaCtrl.text.trim().isEmpty ? 'Tolong isi nama tamu' : null;
      _alamatError = _alamatCtrl.text.trim().isEmpty ? 'Tolong isi alamat tamu' : null;
      _keperluanError = _keperluanCtrl.text.trim().isEmpty ? 'Tolong isi keperluan tamu' : null;
      _fotoError = _fotoTamu == null;

      final jamHIsi = _jamH.text.trim().isNotEmpty;
      final jamMIsi = _jamM.text.trim().isNotEmpty;
      if (jamHIsi || jamMIsi) {
        final jamH = int.tryParse(_jamH.text.trim());
        final jamM = int.tryParse(_jamM.text.trim());
        if (jamH == null || jamM == null ||
            jamH < 0 || jamH > 23 ||
            jamM < 0 || jamM > 59) {
          _jamError = 'Format jam tidak valid (HH:MM)';
        } else {
          _jamError = null;
        }
      } else {
        _jamError = null;
      }
    });

    return _namaError == null &&
        _alamatError == null &&
        _keperluanError == null &&
        !_fotoError &&
        _jamError == null;
  }

  Future<void> _simpanTamu() async {
    if (_isSaving) return;
    if (!_validate()) return;

    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    String? estimasiKeluar;
    final jamHIsi = _jamH.text.trim().isNotEmpty;
    final jamMIsi = _jamM.text.trim().isNotEmpty;
    if (jamHIsi || jamMIsi) {
      final jamH = int.parse(_jamH.text.trim());
      final jamM = int.parse(_jamM.text.trim());
      estimasiKeluar =
          '${jamH.toString().padLeft(2, '0')}:${jamM.toString().padLeft(2, '0')}';
    }

    setState(() => _isSaving = true);
    try {
      final result = await context.read<TamuProvider>().tambahTamu(
        token: token,
        nama: _namaCtrl.text.trim(),
        alamat: _alamatCtrl.text.trim(),
        keperluan: _keperluanCtrl.text.trim(),
        fotoTamu: _fotoTamu!,
        estimasiKeluar: estimasiKeluar,
      );
      if (!result.success) throw Exception(result.message);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _namaError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(25, 16, 25, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Formulir Data Tamu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE55C5C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Nama ──
            _label('Nama Tamu'),
            _field(
              hint: 'Ketikan nama tamu',
              ctrl: _namaCtrl,
              error: _namaError,
              onChanged: (_) => setState(() => _namaError = null),
            ),

            // ── Alamat ──
            _label('Alamat'),
            _field(
              hint: 'Ketikan alamat',
              ctrl: _alamatCtrl,
              error: _alamatError,
              onChanged: (_) => setState(() => _alamatError = null),
            ),

            // ── Keperluan ──
            _label('Keperluan'),
            _field(
              hint: 'Ketikan keperluan tamu',
              ctrl: _keperluanCtrl,
              error: _keperluanError,
              onChanged: (_) => setState(() => _keperluanError = null),
            ),

            // ── Jam Keluar ──
            _label('Jam Keluar (opsional)'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center, // ← center bukan start
              children: [
                _timeBox(_jamH),
                const SizedBox(width: 10),
                const Text(
                  ':',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                _timeBox(_jamM),
              ],
            ),
            if (_jamError != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  _jamError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            // ── Foto Tamu: label di atas, tombol rata kiri di bawah ──
            const SizedBox(height: 6),
            _label('Foto Tamu'),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: _fotoError
                    ? Border.all(color: Colors.red, width: 1.5)
                    : Border.all(color: Colors.transparent),
              ),
              child: Align(
                alignment: Alignment.centerLeft, // ← rata kiri, tidak condong kanan
                child: UploadFotoScreen(
                  onChanged: (foto) => setState(() {
                    _fotoTamu = foto;
                    _fotoError = false;
                  }),
                ),
              ),
            ),
            if (_fotoError)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  'Tolong ambil foto tamu',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            const SizedBox(height: 20),

            // ── Tombol Simpan ──
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : _isFormReady
                        ? _simpanTamu
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isFormReady ? const Color(0xFF034DC0) : Colors.grey.shade400,
                  disabledBackgroundColor:
                      _isFormReady ? const Color(0xFF034DC0) : Colors.grey.shade400,
                  minimumSize: const Size(140, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    ),
  );

  Widget _field({
    required String hint,
    required TextEditingController ctrl,
    String? error,
    ValueChanged<String>? onChanged,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: ctrl,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: error != null ? Colors.red : Colors.black12,
                  width: error != null ? 1.5 : 1.0,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: error != null ? Colors.red : const Color(0xFF034DC0),
                  width: 1.5,
                ),
              ),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      );

  Widget _timeBox(TextEditingController ctrl) => Container(
    width: 55,
    height: 35,
    decoration: BoxDecoration(
      border: Border.all(
        color: _jamError != null ? Colors.red : Colors.black26,
        width: _jamError != null ? 1.5 : 1.0,
      ),
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xFFF5F5F5),
    ),
    child: TextField(
      controller: ctrl,
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: TextInputType.number,
      expands: true,
      minLines: null,
      maxLines: null,
      onChanged: (_) => setState(() => _jamError = null),
      style: const TextStyle(fontSize: 16, height: 1),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
    ),
  );
}