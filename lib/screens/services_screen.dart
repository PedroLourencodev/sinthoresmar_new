import 'package:flutter/material.dart';
import 'benefits_home_screen.dart'; // para abrir a tela de Benefícios via push opcional

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key, required this.onBackToHome});

  /// Callback vindo do main.dart para trocar a aba para Home (índice 0)
  final VoidCallback onBackToHome;

  static const Color azulEscuro = Color(0xFF061A40);
  static const Color laranja    = Color(0xFFFF7F11);
  static const Color cinzaTxt   = Color(0xFF666666);
  static const Color cinzaCampo = Color(0xFFF2F2F2);

  Future<void> _pushSafe(BuildContext context, String routeName) async {
    try {
      await Navigator.of(context).pushNamed(routeName);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rota "$routeName" não encontrada: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulEscuro,
      appBar: AppBar(
        title: const Text('Serviços'),
        centerTitle: true,
        backgroundColor: azulEscuro,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: onBackToHome, // <- volta para a aba Home (não usa Navigator)
          tooltip: 'Ir para Home',
        ),
      ),
      body: Container(
        color: azulEscuro,
        child: Column(
          children: [
            const SizedBox(height: 14),
            const Text(
              'Serviços',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: const Text(
                            'SERVIÇOS DO SINTHORESMAR',
                            style: TextStyle(color: azulEscuro, fontSize: 12.5, fontWeight: FontWeight.w800, letterSpacing: 0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Busca
                      Container(
                        decoration: BoxDecoration(
                          color: cinzaCampo,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar perguntas...',
                            prefixIcon: Icon(Icons.search, color: Color(0xFF9E9E9E)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _gridItem(
                        icon: Icons.help_outline,
                        title: 'FAQ',
                        subtitle: 'Perguntas frequentes',
                        onTap: () => _pushSafe(context, '/faq'),
                      ),
                      const SizedBox(height: 10),

                      _gridItem(
                        icon: Icons.calculate_outlined,
                        title: 'Cálculo Trabalhista',
                        subtitle: 'Rescisão, férias e 13º',
                        onTap: () => _pushSafe(context, '/calculo'),
                      ),
                      const SizedBox(height: 10),

                      _gridItem(
                        icon: Icons.description_outlined,
                        title: 'Requisição de Holerite',
                        subtitle: 'Esta etapa comprova sua associação e habilita o acesso aos benefícios',
                        onTap: () => _pushSafe(context, '/holerite'),
                      ),
                      const SizedBox(height: 10),

                      _gridItem(
                        icon: Icons.calendar_today_outlined,
                        title: 'Agendar Consultoria',
                        subtitle: 'Atendimento jurídico',
                        onTap: () => _pushSafe(context, '/agendamento'),
                      ),
                      const SizedBox(height: 10),

                      _gridItem(
                        icon: Icons.report_gmailerrorred_outlined,
                        title: 'Denúncia Anônima',
                        subtitle: 'Registre sua denúncia',
                        onTap: () => _pushSafe(context, '/denuncia'),
                      ),

                      const SizedBox(height: 28),

                      // Chamada Benefícios
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF2E9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFE1C1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.card_giftcard, color: laranja, size: 28),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Benefícios', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: azulEscuro)),
                                  SizedBox(height: 2),
                                  Text('Conheça todos os benefícios do associado.', style: TextStyle(color: cinzaTxt)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Abre Benefícios via push (independente das tabs)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BenefitsHomeScreen(
                                      onBackToHome: () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: laranja,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Ver'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Center(
                        child: Column(children: [
                          Text(
                            'Dúvidas frequentes',
                            style: TextStyle(color: azulEscuro, fontSize: 15.5, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Encontre respostas rápidas e solicite serviços\nsem sair do aplicativo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: cinzaTxt),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEAEAEA)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: laranja),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: azulEscuro, fontSize: 16.5, fontWeight: FontWeight.w800)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(color: cinzaTxt)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: cinzaTxt),
            ],
          ),
        ),
      ),
    );
  }
}
