import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _sb = Supabase.instance.client;

  Session? get session => _sb.auth.currentSession;
  User? get user => _sb.auth.currentUser;

  Future<void> signOut() async {
    await _sb.auth.signOut();
  }

  /// Busca o nome no perfil; se não houver, retorna null.
  Future<String?> getProfileName() async {
    final u = user;
    if (u == null) return null;
    final rows = await _sb
        .from('profiles')
        .select('name')
        .eq('id', u.id);
    if (rows is List && rows.isNotEmpty) {
      final first = rows.first;
      final name = first['name'];
      if (name is String && name.trim().isNotEmpty) return name;
    }
    return null;
  }
}
