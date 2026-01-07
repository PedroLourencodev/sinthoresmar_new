
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DenunciaAnonimaScreen extends StatefulWidget {
  const DenunciaAnonimaScreen({super.key});
  @override
  State<DenunciaAnonimaScreen> createState() => _DenunciaAnonimaScreenState();
}

class _DenunciaAnonimaScreenState extends State<DenunciaAnonimaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _empresaCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  String _tipo = 'Assédio moral';
  static const _emailDestino = 'contato@sinthoresmar.com.br';

  Future<void> _enviar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final empresa = _empresaCtrl.text.trim();
    final tipo = _tipo;
    final desc = _descricaoCtrl.text.trim();

    final subject = 'Denúncia anônima - $empresa - $tipo';
    final body = [
      'Empresa: $empresa',
      'Tipo: $tipo',
      '',
      'Descrição:',
      desc,
      '',
      '(Enviado via app)'
    ].join('\n');

    final uri = Uri(
      scheme: 'mailto',
      path: _emailDestino,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o e-mail neste dispositivo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Denúncia Anônima')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Envie sua denúncia de forma anônima. Evite dados que revelem sua identidade.',
                    style: TextStyle(color: Colors.black87)),
                const SizedBox(height: 18),

                TextFormField(
                  controller: _empresaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome da empresa',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome da empresa' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _tipo,
                  items: const [
                    DropdownMenuItem(value: 'Assédio moral', child: Text('Assédio moral')),
                    DropdownMenuItem(value: 'Assédio sexual', child: Text('Assédio sexual')),
                    DropdownMenuItem(value: 'Risco à saúde/segurança', child: Text('Risco à saúde/segurança')),
                    DropdownMenuItem(value: 'Irregularidade trabalhista', child: Text('Irregularidade trabalhista')),
                    DropdownMenuItem(value: 'Outros', child: Text('Outros')),
                  ],
                  onChanged: (v) => setState(() => _tipo = v ?? _tipo),
                  decoration: const InputDecoration(
                    labelText: 'Tipo de denúncia',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descricaoCtrl,
                  minLines: 6,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (detalhes do ocorrido, local, datas…)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Descreva com pelo menos 10 caracteres'
                      : null,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _enviar,
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Enviar por e-mail'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('O app abrirá seu aplicativo de e-mail já preenchido para você enviar.',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
