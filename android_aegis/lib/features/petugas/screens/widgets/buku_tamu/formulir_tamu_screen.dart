import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

  Future<void> _simpanTamu() async {
    if (_isSaving) return;

    final nama = _namaCtrl.text.trim();
    final alamat = _alamatCtrl.text.trim();
    final keperluan = _keperluanCtrl.text.trim();
    final auth = context.read<AuthProvider>();
    final token = auth.token;

    if (nama.isEmpty || alamat.isEmpty || keperluan.isEmpty) {
      _showMessage('Nama, alamat, dan keperluan wajib diisi.');
      return;
    }

    if (_fotoTamu == null) {
      _showMessage('Foto tamu wajib diambil.');
      return;
    }

    if (token == null) {
      _showMessage('Sesi login tidak ditemukan. Silakan login ulang.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final result = await context.read<TamuProvider>().tambahTamu(
        token: token,
        nama: nama,
        alamat: alamat,
        keperluan: keperluan,
        fotoTamu: _fotoTamu!,
      );

      if (!result.success) {
        throw Exception(result.message);
      }

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  @override
  Widget build(BuildContext context) {
    return Container(
      // Latar belakang Putih (FFFFFF) dengan sudut melengkung di atas
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Judul & Tombol Close Merah Bulat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Formulir Data Tamu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE55C5C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            _label('Nama Tamu'),
            _field('Ketikan nama tamu', _namaCtrl),

            _label('Alamat'),
            _field('Ketikan alamat', _alamatCtrl),

            _label('Keperluan'),
            _field('Ketikan keperluan tamu', _keperluanCtrl),

            _label('Jam Masuk'),
            Row(
              children: [
                _timeBox(_jamH),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    ':',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                _timeBox(_jamM),
              ],
            ),

            const SizedBox(height: 25),
            _label('Foto Tamu'),

            // Memanggil widget Kamera (Kotak Besar)
            UploadFotoScreen(onChanged: (foto) => _fotoTamu = foto),

            const SizedBox(height: 35),

            // Tombol Simpan Biru
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _simpanTamu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF034DC0),
                  minimumSize: const Size(140, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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
    padding: const EdgeInsets.only(top: 15, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.black,
      ),
    ),
  );

  Widget _field(String hint, TextEditingController ctrl) => TextField(
    controller: ctrl,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black12),
      ),
    ),
  );

  Widget _timeBox(TextEditingController ctrl) => Container(
    width: 60,
    height: 35,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black26),
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
