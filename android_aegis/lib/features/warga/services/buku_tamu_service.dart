import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_client.dart';
import '../models/buku_tamu_model.dart';

class BukuTamuService {
  Future<List<BukuTamuModel>> getBukuTamu({
    required String token,
    String? tanggal,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (tanggal != null) queryParams['tanggal'] = tanggal;
    if (search != null) queryParams['search'] = search;

    final uri = Uri.parse('${ApiClient.baseUrl}/warga/buku-tamu')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: ApiClient.headers(token: token),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => BukuTamuModel.fromJson(e)).toList();
    }

    throw Exception(
        jsonDecode(response.body)['message'] ?? 'Gagal memuat buku tamu');
  }
}
