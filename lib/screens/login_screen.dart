import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'associe_se_screen.dart'; // << trocado: antes era register_screen.dart

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String route = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Cores (mantém seu visual)
  static const Color azulEscuro = Color(0xFF061A40);
  static const Color vermelho = Color(0xFFFF3B30);

  // Controllers
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: success ? Colors.green : null),
    );
  }

  Future<void> _doLogin() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      _snack('Preencha e-mail e senha.');
      return;
    }

    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;

      // 1) Autentica
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: pass,
      );

      // 2) Garante/atualiza perfil (opcional)
      final uid = res.user!.id;
      await supabase.from('profiles').upsert({
        'id': uid,
        'email': email,
        'name': 'Usuário', // troque quando tiver campo de nome
      });

      if (!mounted) return;
      _snack('Login realizado!', success: true);
      Navigator.pop(context); // volta para a Home
    } on AuthException catch (e) {
      _snack(e.message);
    } catch (e) {
      _snack('Erro inesperado: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _irParaAssocieSe() {
    Navigator.pushNamed(context, AssocieSeScreen.route);
    // Alternativa sem rota nomeada:
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (_) => const AssocieSeScreen()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulEscuro,
      appBar: AppBar(
        backgroundColor: azulEscuro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Voltar',
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/sinthoresmar_logo.png',
                width: 28, height: 28, fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Text('SINTHORESMAR',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Image.asset('assets/images/sinthoresmar_logo.png',
                    height: 120, fit: BoxFit.contain),
                const SizedBox(height: 16),

                // Campo e-mail
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'E-mail',
                    filled: true,
                    fillColor: const Color(0xFFF6F6F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),

                // Campo senha
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Senha',
                    filled: true,
                    fillColor: const Color(0xFFF6F6F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botão entrar
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vermelho,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: _loading ? null : _doLogin,
                    child: _loading
                        ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : const Text('ENTRAR'),
                  ),
                ),

                const SizedBox(height: 10),

                // >>> Botão "Associe-se" (substitui o antigo "Cadastre-se")
                TextButton(
                  onPressed: _irParaAssocieSe,
                  child: const Text(
                    'Associe-se',
                    style: TextStyle(
                      color: Color(0xFF1B60E8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Links inferiores
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 18,
                    runSpacing: 4,
                    children: [
                      _LinkText('Esqueci minha senha', () async {
                        final email = _emailCtrl.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          _snack('Informe um e-mail válido para recuperar a senha.');
                          return;
                        }
                        try {
                          await Supabase.instance.client.auth.resetPasswordForEmail(email);
                          _snack('Se existir uma conta para $email, enviaremos instruções.');
                        } catch (e) {
                          _snack('Não foi possível iniciar a recuperação agora.');
                        }
                      }),
                      const _DividerDot(),
                      _LinkText('Termos de uso', () { Navigator.of(context).pushNamed('/terms'); }),
                      const _DividerDot(),
                      _LinkText('Política de privacidade', () { Navigator.of(context).pushNamed('/privacy'); }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const _LinkText(this.text, [this.onTap]);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF555555),
          fontSize: 13,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

class _DividerDot extends StatelessWidget {
  const _DividerDot();
  @override
  Widget build(BuildContext context) {
    return const Text('•', style: TextStyle(color: Color(0xFFAAAAAA)));
  }
}
