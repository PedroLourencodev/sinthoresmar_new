import 'package:flutter/material.dart';
import 'benefits_list_screen.dart'; // comente se não existir no projeto

class BenefitsHomeScreen extends StatelessWidget {
  const BenefitsHomeScreen({super.key, required this.onBackToHome});

  /// Callback vindo do main.dart para trocar a aba para Home (índice 0)
  /// ou um callback local (quando aberta via push) para dar pop.
  final VoidCallback onBackToHome;

  static const Color azulEscuro = Color(0xFF061A40);
  static const Color laranja    = Color(0xFFFF7F11);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulEscuro,
      appBar: AppBar(
        title: const Text('Benefícios'),
        centerTitle: true,
        backgroundColor: azulEscuro,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: onBackToHome, // <- volta para Home (via callback) ou dá pop se foi aberto via push
          tooltip: 'Ir para Home',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Image.asset('assets/images/sinthoresmar_logo.png', height: 100),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    const Text(
                      'Conheça seus benefícios',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: azulEscuro),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Como associado, você tem direito a diversos benefícios. Toque para ver a lista completa.',
                      style: TextStyle(color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BenefitsListScreen()),
                        );
                      },
                      icon: const Icon(Icons.card_giftcard),
                      label: const Text('Ver Benefícios'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: laranja,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // conteúdo extra...
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
