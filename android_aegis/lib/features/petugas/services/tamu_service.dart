import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

import '../../../core/services/api_client.dart';
import '../models/tamu_model.dart';

class TamuService {
  static Future<List<TamuModel>> fetchAll({required String token}) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/tamu'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Gagal mengambil data tamu.');
    }

    final data = (body['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(TamuModel.fromJson)
        .toList();

    return data;
  }

  static Future<Map<String, dynamic>> store({
    required String token,
    required String nama,
    required String alamat,
    required String keperluan,
    required XFile fotoTamu,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiClient.baseUrl}/tamu'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields.addAll({
      'nama': nama,
      'alamat': alamat,
      'keperluan': keperluan,
      'status': 'masuk',
    });

    final bytes = await fotoTamu.readAsBytes();
    final filename = fotoTamu.name.isNotEmpty
        ? fotoTamu.name
        : 'foto_tamu_${DateTime.now().millisecondsSinceEpoch}.jpg';

    request.files.add(
      http.MultipartFile.fromBytes('foto_tamu', bytes, filename: filename),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Gagal menyimpan data tamu.');
    }

    return body;
  }

  static Future<void> markKeluar({
    required String token,
    required int tamuId,
    required DateTime waktuKeluar,
  }) async {
    final waktuKeluarIso = waktuKeluar.toIso8601String();
    final waktuKeluarJam =
        '${waktuKeluar.hour.toString().padLeft(2, '0')}:'
        '${waktuKeluar.minute.toString().padLeft(2, '0')}';

    final attempts = <Future<http.Response> Function()>[
      () => http.patch(
        Uri.parse('${ApiClient.baseUrl}/tamu/$tamuId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'status': 'keluar',
          'waktu_keluar': waktuKeluarIso,
          'jam_keluar': waktuKeluarJam,
        },
      ),
      () => http.post(
        Uri.parse('${ApiClient.baseUrl}/tamu/$tamuId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          '_method': 'PATCH',
          'status': 'keluar',
          'waktu_keluar': waktuKeluarIso,
          'jam_keluar': waktuKeluarJam,
        },
      ),
      () => http.put(
        Uri.parse('${ApiClient.baseUrl}/tamu/$tamuId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'status': 'keluar',
          'waktu_keluar': waktuKeluarIso,
          'jam_keluar': waktuKeluarJam,
        },
      ),
    ];

    Object? lastError;

    for (final request in attempts) {
      final response = await request();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic> && decoded['message'] != null) {
            lastError = decoded['message'];
          } else {
            lastError = response.body;
          }
        } catch (_) {
          lastError = response.body;
        }
      } else {
        lastError = 'HTTP ${response.statusCode}';
      }
    }

    throw Exception(
      lastError is String && lastError.trim().isNotEmpty
          ? lastError
          : 'Gagal mengubah status tamu.',
    );
  }
}
