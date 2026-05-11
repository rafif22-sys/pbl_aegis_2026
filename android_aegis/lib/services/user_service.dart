import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class UserService {
  final _supabase = SupabaseService().client;

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    return await getUserByEmail(user.email!);
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _supabase
        .from('users')
        .update(user.toJson())
        .eq('id', user.id);
  }
}
