import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sos_report.dart';
import 'supabase_service.dart';

class SosService {
  final _supabase = SupabaseService().client;

  Future<List<SosReport>> getSosReports(String userId) async {
    final response = await _supabase
        .from('sos_reports')
        .select()
        .eq('user_id', userId)
        .order('waktu', ascending: false);

    return (response as List)
        .map((json) => SosReport.fromJson(json))
        .toList();
  }

  Future<SosReport> createSosReport(SosReport report) async {
    final response = await _supabase
        .from('sos_reports')
        .insert(report.toJson())
        .select()
        .single();

    return SosReport.fromJson(response);
  }

  Future<void> updateSosStatus(String id, String status) async {
    await _supabase
        .from('sos_reports')
        .update({'status': status})
        .eq('id', id);
  }
}
