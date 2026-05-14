import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class UploadFotoScreen extends StatefulWidget {
  const UploadFotoScreen({super.key, this.onChanged});

  final ValueChanged<XFile?>? onChanged;

  @override
  State<UploadFotoScreen> createState() => _UploadFotoScreenState();
}

class _UploadFotoScreenState extends State<UploadFotoScreen> {
  XFile? _imageFile;

  Future<void> _openCameraDialog() async {
    final photo = await showDialog<XFile>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CameraCaptureDialog(),
    );

    if (!mounted || photo == null) return;
    setState(() => _imageFile = photo);
    widget.onChanged?.call(photo);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildPhotoContent(),
          Positioned(
            right: 12,
            bottom: 12,
            child: ElevatedButton.icon(
              onPressed: _openCameraDialog,
              icon: Icon(
                _imageFile == null
                    ? Icons.camera_alt_rounded
                    : Icons.refresh_rounded,
                size: 18,
              ),
              label: Text(_imageFile == null ? 'Ambil Foto' : 'Foto Ulang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF034DC0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoContent() {
    if (_imageFile != null) {
      return _CapturedPhotoPreview(imageFile: _imageFile!);
    }

    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.camera_alt_rounded,
          size: 48,
          color: Color(0xFF034DC0),
        ),
        SizedBox(height: 12),
        Text(
          'Belum ada foto tamu',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CapturedPhotoPreview extends StatelessWidget {
  const _CapturedPhotoPreview({required this.imageFile});

  final XFile imageFile;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Image.file(File(imageFile.path), fit: BoxFit.cover);
    }

    return FutureBuilder(
      future: imageFile.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF034DC0)),
          );
        }

        return Image.memory(snapshot.data!, fit: BoxFit.cover);
      },
    );
  }
}

class _CameraCaptureDialog extends StatefulWidget {
  const _CameraCaptureDialog();

  @override
  State<_CameraCaptureDialog> createState() => _CameraCaptureDialogState();
}

class _CameraCaptureDialogState extends State<_CameraCaptureDialog> {
  CameraController? _cameraController;
  String? _errorMessage;
  bool _isInitializing = true;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('no_camera', 'Tidak ada kamera yang tersedia.');
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isInitializing = false;
      });
    } catch (e) {
      debugPrint('Gagal membuka kamera: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Kamera tidak bisa dibuka. Cek izin kamera perangkat.';
        _isInitializing = false;
      });
    }
  }

  Future<void> _takePicture() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isTakingPicture) {
      return;
    }

    setState(() => _isTakingPicture = true);
    try {
      final photo = await controller.takePicture();
      if (!mounted) return;
      Navigator.pop(context, photo);
    } catch (e) {
      debugPrint('Gagal mengambil foto: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto gagal diambil. Coba lagi.')),
      );
      setState(() => _isTakingPicture = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                color: Colors.black,
                child: _buildCameraContent(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isTakingPicture ? null : _takePicture,
                      icon: const Icon(Icons.camera_alt_rounded, size: 18),
                      label: Text(_isTakingPicture ? 'Memotret...' : 'Ambil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF034DC0),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF0F172A),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Ambil Foto Tamu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Tutup',
          ),
        ],
      ),
    );
  }

  Widget _buildCameraContent() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      );
    }

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: Text(
          'Kamera belum siap.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.previewSize?.height ?? 520,
        height: controller.value.previewSize?.width ?? 390,
        child: CameraPreview(controller),
      ),
    );
  }
}
