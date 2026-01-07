
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class AgendarConsultoriaScreen extends StatelessWidget {
  const AgendarConsultoriaScreen({super.key});

  static const String _phone = '5514998799263'; // +55 14 99879-9263

  Future<void> _abrirWhatsapp(BuildContext context) async {
    final msg = Uri.encodeComponent('Olá! Gostaria de agendar uma consultoria jurídica.');
    final uri = Uri.parse('https://wa.me/$_phone?text=$msg');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Consultoria')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Toque no botão para iniciar seu atendimento via WhatsApp.'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _abrirWhatsapp(context),
                icon: const FaIcon(FontAwesomeIcons.whatsapp),
                label: const Text('Abrir WhatsApp'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
