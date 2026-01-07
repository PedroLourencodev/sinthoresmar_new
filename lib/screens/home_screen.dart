import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';
import '../services/auth_service.dart';

// Notícias
import '../services/news_service.dart';
import '../models/news.dart';
import 'news_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Paleta
  static const Color azulEscuro = Color(0xFF061A40);
  static const Color vermelho = Color(0xFFFF3B30);
  static const Color cinzaTexto = Color(0xFF666666);

  String? _greetingName;
  User? _user;

  @override
  void initState() {
    super.initState();
    _hydrate();
    Supabase.instance.client.auth.onAuthStateChange.listen((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    final auth = AuthService.instance;
    final currentUser = auth.user;
    String? name;
    if (currentUser != null) name = await auth.getProfileName();
    if (!mounted) return;
    setState(() {
      _user = currentUser;
      _greetingName = name;
    });
  }

  void _openAccountActions() {
    if (_user == null) {
      Navigator.pushNamed(context, LoginScreen.route);
      return;
    }
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final email = _user?.email ?? '';
        final display = (_greetingName?.trim().isNotEmpty ?? false)
            ? _greetingName!.trim()
            : email;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: Text(display),
                subtitle: const Text('Sua conta'),
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sair'),
                onTap: () async {
                  await AuthService.instance.signOut();
                  if (!mounted) return;
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }

  String _summary(String? content, {int max = 120}) {
    if (content == null) return '';
    final t = content.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.isEmpty) return '';
    return t.length <= max ? t : '${t.substring(0, max)}...';
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 360;
    final String chipText = _user == null
        ? 'Entrar'
        : ((_greetingName != null && _greetingName!.trim().isNotEmpty)
        ? 'Olá, ${_greetingName!.trim()}'
        : 'Olá, ${_user!.email ?? 'Usuário'}');

    return Container(
      color: azulEscuro,
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ===================== HEADER =====================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/sinthoresmar_logo.png',
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'SINTHORESMAR',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // CHIP de conta
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _openAccountActions,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isCompact)
                              Text(
                                chipText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            if (!isCompact) const SizedBox(width: 8),
                            const Icon(Icons.account_circle, color: Colors.white, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ==================================================

          // ===================== CONTEÚDO ====================
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: RefreshIndicator(
                onRefresh: () async => setState(() {}),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  // >>> AQUI usamos FutureBuilder para testar SELECT direto <<<
                  child: FutureBuilder<List<News>>(
                    future: NewsService.instance.fetchLatest(limit: 50),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Erro no fetch: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final items = snapshot.data ?? const <News>[];
                      final hasFeatured = items.isNotEmpty;
                      final News? featured = hasFeatured ? items.first : null;
                      final rest = hasFeatured ? items.skip(1).toList() : <News>[];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---------- CARD DESTAQUE (automático) ----------
                          _FeaturedCard(
                            news: featured,
                            fallbackBorderColor: vermelho,
                            summaryFn: _summary,
                          ),

                          const SizedBox(height: 18),

                          // ---------- TÍTULO LISTA ----------
                          const Text(
                            'Últimas notícias',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (rest.isEmpty && !hasFeatured)
                            const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text(
                                'Nenhuma notícia publicada ainda.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                          else
                            Column(
                              children: rest
                                  .map((n) =>
                                  _NewsListTile(news: n, summaryFn: _summary))
                                  .toList(),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // ==================================================
        ],
      ),
    );
  }
}

// =================== CARD DESTAQUE ===================
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.news,
    required this.fallbackBorderColor,
    required this.summaryFn,
  });

  final News? news;
  final Color fallbackBorderColor;
  final String Function(String? content, {int max}) summaryFn;

  @override
  Widget build(BuildContext context) {
    if (news == null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: fallbackBorderColor, width: 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1520975916090-3105956dac38?q=80&w=1200&auto=format&fit=crop',
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black.withOpacity(0.45),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOTÍCIAS EM DESTAQUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Acompanhe as últimas atualizações do sindicato.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final imageUrl = news!.imageUrl;
    final summary = summaryFn(news!.content, max: 140);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news!)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: fallbackBorderColor, width: 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            if (imageUrl == null || imageUrl.isEmpty)
              Container(
                width: double.infinity,
                height: 180,
                color: const Color(0xFFEDEFF3),
                child: const Icon(Icons.image_outlined, size: 36),
              )
            else
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 180,
                  color: const Color(0xFFEDEFF3),
                  child: const Icon(Icons.broken_image_outlined, size: 36),
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black.withOpacity(0.45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news!.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (summary.isNotEmpty)
                    Text(
                      summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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
}

// =============== ITEM DA LISTA (restante) ===============
class _NewsListTile extends StatelessWidget {
  const _NewsListTile({required this.news, required this.summaryFn});
  final News news;
  final String Function(String? content, {int max}) summaryFn;

  static const Color azulEscuro = Color(0xFF061A40);
  static const Color cinzaTexto = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    final imageUrl = news.imageUrl;
    final summary = summaryFn(news.content);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // thumb
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (imageUrl == null || imageUrl.isEmpty)
                  ? Container(
                width: 78,
                height: 78,
                color: const Color(0xFFEDEFF3),
                child: const Icon(Icons.image_not_supported_outlined),
              )
                  : Image.network(
                imageUrl,
                width: 78,
                height: 78,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 78,
                  height: 78,
                  color: const Color(0xFFEDEFF3),
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: azulEscuro,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (summary.isNotEmpty)
                    Text(
                      summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: cinzaTexto,
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
}
