// lib/features/petugas/repositories/patroli_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_client.dart';
import '../models/patroli_model.dart';

class PatroliRepository {
  static String get _base => ApiClient.baseUrl;

  // ── GET sesi patroli ─────────────────────────────────────────────────────
  Future<PatroliModel> getSesi({
    required String token,
    required int idJadwalAbsensi,
  }) async {
    final res = await http.get(
      Uri.parse('$_base/petugas/patroli/$idJadwalAbsensi'),
      headers: ApiClient.headers(token: token),
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 200 || body['status'] == false) {
      throw Exception(body['message'] ?? 'Gagal memuat sesi patroli');
    }

    return PatroliModel.fromJson(body['data']);
  }

  // ── POST update lokasi petugas (periodik) ────────────────────────────────
  Future<void> updateLokasi({
    required String token,
    required int idJadwalAbsensi,
    required double latitude,
    required double longitude,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/petugas/patroli/$idJadwalAbsensi/lokasi'),
      headers: ApiClient.headers(token: token),
      body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 200 || body['status'] == false) {
      throw Exception(body['message'] ?? 'Gagal update lokasi');
    }
  }
}