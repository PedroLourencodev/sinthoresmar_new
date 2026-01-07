import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key, required this.onBackToHome});
  static const route = '/contacts';

  /// Callback vindo do main.dart para trocar a aba para Home (índice 0)
  final VoidCallback onBackToHome;

  static const Color azulEscuro = Color(0xFF061A40);
  static const String _phoneMarilia  = '+5514998799263';
  static const String _phoneOurinhos = '+5514996761982';
  static const String _email         = 'contato@sinthoresmar.com.br';
  static const String _igUser        = 'sinthoressmar';
  static const String _addrMarilia   = 'Rua São Luiz, 88 - Marília/SP';
  static const String _addrOurinhos  = 'Travessa Treze de Dezembro, 111 - Ourinhos/SP';

  Widget _backLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      onPressed: onBackToHome, // <- volta para a aba Home (não usa Navigator)
      tooltip: 'Voltar',
    );
  }

  Future<void> _call(BuildContext ctx, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) _oops(ctx, 'Não foi possível abrir o discador.');
  }

  Future<void> _whatsapp(BuildContext ctx, String phone) async {
    final uri = Uri.parse('https://wa.me/${phone.replaceAll('+', '')}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _oops(ctx, 'Não foi possível abrir o WhatsApp.');
    }
  }

  Future<void> _maps(BuildContext ctx, String query) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _oops(ctx, 'Não foi possível abrir o Maps.');
    }
  }

  Future<void> _emailTo(BuildContext ctx) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      query: Uri.encodeQueryComponent('subject=Contato via app&body=Olá, gostaria de...'),
    );
    if (!await launchUrl(uri)) _oops(ctx, 'Não foi possível abrir o e-mail.');
  }

  Future<void> _instagram(BuildContext ctx) async {
    final uri = Uri.parse('https://instagram.com/$_igUser');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _oops(ctx, 'Não foi possível abrir o Instagram.');
    }
  }

  void _oops(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }

  ButtonStyle _btnStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFFF6A3D),
      side: const BorderSide(color: Color(0xFFFF6A3D)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);
    final caption    = Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulEscuro,
        elevation: 0,
        title: const Text('Contatos'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: _backLeading(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cardIntro(titleStyle, caption),

          _placeCard(
            context,
            title: 'Marília',
            address: _addrMarilia,
            schedule: 'Seg a Sex: 8h às 18h',
            onCall: () => _call(context, _phoneMarilia),
            onWhatsapp: () => _whatsapp(context, _phoneMarilia),
            onMaps: () => _maps(context, _addrMarilia),
          ),

          _placeCard(
            context,
            title: 'Ourinhos',
            address: _addrOurinhos,
            schedule: 'Seg a Sex: 8h às 18h',
            onCall: () => _call(context, _phoneOurinhos),
            onWhatsapp: () => _whatsapp(context, _phoneOurinhos),
            onMaps: () => _maps(context, _addrOurinhos),
          ),

          const Divider(height: 32),

          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('E-mail'),
            subtitle: const Text(_email),
            trailing: OutlinedButton.icon(
              onPressed: () => _emailTo(context),
              icon: const Icon(Icons.send),
              label: const Text('Enviar e-mail'),
              style: _btnStyle(),
            ),
          ),

          const Divider(height: 32),

          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Redes sociais'),
            subtitle: Text('Instagram: @$_igUser'),
            trailing: OutlinedButton(
              onPressed: () => _instagram(context),
              style: _btnStyle(),
              child: const Text('Abrir Instagram'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardIntro(TextStyle? titleStyle, TextStyle? caption) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.support_agent, size: 36, color: azulEscuro),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fale Conosco', style: titleStyle),
                  const SizedBox(height: 4),
                  Text('Estamos disponíveis para te ajudar!', style: caption),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _placeCard(
      BuildContext context, {
        required String title,
        required String address,
        String? schedule,
        required VoidCallback onCall,
        required VoidCallback onWhatsapp,
        required VoidCallback onMaps,
      }) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(address),
            if (schedule != null) ...[
              const SizedBox(height: 2),
              const Text('Horário de atendimento:', style: TextStyle(color: Color(0xFF6B7280))),
              Text(schedule),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.phone),
                  label: const Text('Ligar'),
                  style: _btnStyle(),
                ),
                OutlinedButton.icon(
                  onPressed: onWhatsapp,
                  icon: const FaIcon(FontAwesomeIcons.whatsapp),
                  label: const Text('WhatsApp'),
                  style: _btnStyle(),
                ),
                OutlinedButton.icon(
                  onPressed: onMaps,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Abrir no Maps'),
                  style: _btnStyle(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
