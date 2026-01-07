import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:brasil_fields/brasil_fields.dart' as brasil_fields;

// >>> Supabase (precisa já ter inicializado no main.dart)
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AssocieSeScreen extends StatefulWidget {
  const AssocieSeScreen({super.key});

  static const String route = '/associe-se';

  @override
  State<AssocieSeScreen> createState() => _AssocieSeScreenState();
}

class _AssocieSeScreenState extends State<AssocieSeScreen> {
  // Mesma cor do AppBar do login
  static const Color azulEscuro = Color(0xFF061A40);

  final _formKey = GlobalKey<FormState>();
  final _scroll = ScrollController();

  // --------- Controllers: CARD 1
  final nomeCtrl = TextEditingController();
  final emailCtrl = TextEditingController();      // e-mail
  final senhaCtrl = TextEditingController();      // senha
  bool _obscurePass = true;

  final dnCtrl = TextEditingController();
  final endCtrl = TextEditingController();
  final cepCtrl = TextEditingController();
  final bairroCtrl = TextEditingController();
  final cidadeCtrl = TextEditingController();
  String? uf;
  final filiacaoCtrl = TextEditingController();
  final nacionalidadeCtrl = TextEditingController();
  final naturalCtrl = TextEditingController();
  final cpfCtrl = TextEditingController();
  final rgCtrl = TextEditingController();

  // --------- Controllers: CARD 2
  final ctpsCtrl = TextEditingController();
  final serieCtrl = TextEditingController();
  String? estadoCivil;
  String? sexo;
  String? instrucao;
  final telefoneCtrl = TextEditingController();

  // --------- Dependentes
  final List<_DepForm> dependentes = [];

  // --------- Listas
  static const ufs = [
    'AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG',
    'PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO'
  ];
  static const estadosCivis = [
    'Solteiro(a)','Casado(a)','Divorciado(a)','Viúvo(a)','União Estável'
  ];
  static const sexos = ['Masculino','Feminino','Prefiro não informar'];
  static const instrucoes = [
    'Fundamental','Médio','Técnico','Superior','Pós-graduação','Mestrado','Doutorado'
  ];
  static const parentescos = ['Filho(a)','Cônjuge','Pai/Mãe','Outro'];

  // --------- Helpers
  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  DateTime? _parseDate(String v) {
    try { return DateFormat('dd/MM/yyyy').parseStrict(v); }
    catch (_) { return null; }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  String? _validateTitularBirth(String? v) {
    if (_required(v) != null) return 'Campo obrigatório';
    final dt = _parseDate(v!.trim());
    if (dt == null) return 'Data inválida';
    if (dt.isAfter(DateTime.now())) return 'Não pode ser futura';
    final min14 = DateTime(DateTime.now().year - 14, DateTime.now().month, DateTime.now().day);
    if (dt.isAfter(min14)) return 'Titular deve ter pelo menos 14 anos';
    return null;
  }

  String? _validateCPF(String? v) {
    if (_required(v) != null) return 'Campo obrigatório';
    if (!brasil_fields.CPFValidator.isValid(v)) return 'CPF inválido';
    return null;
  }

  String? _validateFone(String? v) {
    if (_required(v) != null) return 'Campo obrigatório';
    final d = v!.replaceAll(RegExp(r'\D'), '');
    return d.length < 10 ? 'Telefone incompleto' : null;
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Campo obrigatório';
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!re.hasMatch(value)) return 'E-mail inválido';
    return null;
  }

  String? _validateSenha(String? v) {
    final x = (v ?? '').trim();
    if (x.isEmpty) return 'Campo obrigatório';
    if (x.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  void _addDep() => setState(() => dependentes.add(_DepForm()));
  void _removeDep(int i) => setState(() => dependentes.removeAt(i));

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scroll.hasClients) {
        _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
      return;
    }

    final payload = {
      "nome": nomeCtrl.text.trim(),
      "email": emailCtrl.text.trim().toLowerCase(),
      "data_nascimento": _parseDate(dnCtrl.text)?.toIso8601String(),
      "endereco": endCtrl.text.trim(),
      "cep": cepCtrl.text.trim(),
      "bairro": bairroCtrl.text.trim(),
      "cidade": cidadeCtrl.text.trim(),
      "uf": uf,
      "filiacao": filiacaoCtrl.text.trim(),
      "nacionalidade": nacionalidadeCtrl.text.trim(),
      "natural": naturalCtrl.text.trim(),
      "cpf": cpfCtrl.text.trim(),
      "rg": rgCtrl.text.trim(),
      "ctps_numero": ctpsCtrl.text.trim(),
      "ctps_serie": serieCtrl.text.trim(),
      "estado_civil": estadoCivil,
      "sexo": sexo,
      "grau_instrucao": instrucao,
      "telefone": telefoneCtrl.text.trim(),
      "dependentes": dependentes.map((d) => {
        "nome": d.nome.text.trim(),
        "parentesco": d.parentesco,
        "data_nascimento": _parseDate(d.data.text)?.toIso8601String(),
      }).toList(),
    };

    final supabase = Supabase.instance.client;

    // Ajuste estas URLs:
    final redirectTo = kIsWeb
        ? 'https://seu-dominio.com/auth/callback' // URL web que receberá o callback
        : 'com.sindicato.app://login-callback';   // Deep link do app (Android/iOS)

    try {
      final res = await supabase.auth.signUp(
        email: payload['email'] as String,
        password: senhaCtrl.text,
        data: payload,                // salva metadados no user
        emailRedirectTo: redirectTo,  // envia link de confirmação
      );

      if (res.user != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Cadastro iniciado! Enviamos um e-mail de confirmação. '
                    'Confira sua caixa de entrada e ative a conta pelo link.'
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de autenticação: ${e.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro inesperado: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in [
      nomeCtrl,emailCtrl,senhaCtrl,  // inclui senha
      dnCtrl,endCtrl,cepCtrl,bairroCtrl,cidadeCtrl,
      filiacaoCtrl,nacionalidadeCtrl,naturalCtrl,cpfCtrl,rgCtrl,
      ctpsCtrl,serieCtrl,telefoneCtrl
    ]) { c.dispose(); }
    for (final d in dependentes) { d.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= 1200 ? 3 : (w >= 900 ? 2 : 1);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulEscuro,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: const Text(
          'Associe-se',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF1B1F24),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.all(20),
          child: switch (cols) {
            3 => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _cardDados()),
                const SizedBox(width: 20),
                Expanded(child: _cardComplementares()),
                const SizedBox(width: 20),
                Expanded(child: _cardDependentes()),
              ],
            ),
            2 => Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _cardDados()),
                    const SizedBox(width: 20),
                    Expanded(child: _cardComplementares()),
                  ],
                ),
                const SizedBox(height: 20),
                _cardDependentes(),
              ],
            ),
            _ => Column(
              children: [
                _cardDados(),
                const SizedBox(height: 20),
                _cardComplementares(),
                const SizedBox(height: 20),
                _cardDependentes(),
              ],
            ),
          },
        ),
      ),
    );
  }

  // ----------------- CARD 1: DADOS CADASTRAIS -----------------
  Widget _cardDados() {
    return _Card(
      title: 'Dados Cadastrais',
      child: Column(
        children: [
          TextFormField(
            controller: nomeCtrl,
            decoration: _dec('Nome *', hint: 'Nome completo'),
            validator: _required,
          ),
          const SizedBox(height: 12),

          // --------- E-MAIL
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: _dec('E-mail *', hint: 'seuemail@exemplo.com'),
            validator: _validateEmail,
          ),
          const SizedBox(height: 12),

          // --------- SENHA
          TextFormField(
            controller: senhaCtrl,
            obscureText: _obscurePass,
            keyboardType: TextInputType.visiblePassword,
            decoration: _dec('Senha *', hint: 'mín. 8 caracteres').copyWith(
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator: _validateSenha,
          ),
          const SizedBox(height: 12),

          // Data de nascimento — manual (sem ícone/picker)
          TextFormField(
            controller: dnCtrl,
            decoration: _dec('dd / mm / aaaa'),
            keyboardType: TextInputType.datetime,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              brasil_fields.DataInputFormatter(),
            ],
            validator: _validateTitularBirth,
          ),
          const SizedBox(height: 12),
          TextFormField(
              controller: endCtrl, decoration: _dec('Endereço *'), validator: _required),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: cepCtrl,
                  decoration: _dec('CEP *'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    brasil_fields.CepInputFormatter(ponto: false),
                  ],
                  validator: _required,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: bairroCtrl, decoration: _dec('Bairro *'), validator: _required)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextFormField(controller: cidadeCtrl, decoration: _dec('Cidade *'), validator: _required)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: uf,
                  decoration: _dec('UF *'),
                  items: ufs.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => uf = v),
                  validator: (v) => v == null ? 'Selecione' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(controller: filiacaoCtrl, decoration: _dec('Filiação')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextFormField(controller: nacionalidadeCtrl, decoration: _dec('Nacionalidade'))),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: naturalCtrl, decoration: _dec('Natural'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: cpfCtrl,
                  decoration: _dec('CPF *'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    brasil_fields.CpfInputFormatter(),
                  ],
                  validator: _validateCPF,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: rgCtrl, decoration: _dec('RG *'), validator: _required)),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------- CARD 2: COMPLEMENTARES + HEADER DEPENDENTES -----------------
  Widget _cardComplementares() {
    return _Card(
      title: 'Dependentes',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextFormField(controller: ctpsCtrl, decoration: _dec('CTPS Nº'), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: serieCtrl, decoration: _dec('Série'), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: estadoCivil, decoration: _dec('Estado Civil *'),
                  items: estadosCivis.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => estadoCivil = v),
                  validator: (v) => v == null ? 'Selecione' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: sexo, decoration: _dec('Sexo *'),
                  items: sexos.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => sexo = v),
                  validator: (v) => v == null ? 'Selecione' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: instrucao, decoration: _dec('Grau de Instrução *'),
            items: instrucoes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => instrucao = v),
            validator: (v) => v == null ? 'Selecione' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: telefoneCtrl, decoration: _dec('Telefone *'),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              brasil_fields.TelefoneInputFormatter(),
            ],
            validator: _validateFone,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Dependentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                tooltip: 'Adicionar dependente',
                onPressed: _addDep,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF2979FF),
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (dependentes.isNotEmpty)
            _DepPreview(
              form: dependentes.first,
              parentescos: parentescos,
              dec: _dec,
            )
          else
            const Text('Nenhum dependente adicionado.', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // ----------------- CARD 3: LISTA DEPENDENTES + SUBMIT -----------------
  Widget _cardDependentes() {
    return _Card(
      title: 'Dependentes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (dependentes.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Adicione dependentes pelo botão [+] no card do meio.', style: TextStyle(color: Colors.white70)),
            ),
          for (int i = 0; i < dependentes.length; i++) ...[
            Row(
              children: [
                Text('Dependente ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _removeDep(i),
                  child: const Text('Remover'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: dependentes[i].nome,
              decoration: _dec('Nome do Dependente *'),
              validator: (v) => _required(v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: dependentes[i].parentesco,
                    decoration: _dec('Parentesco *'),
                    items: parentescos.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => dependentes[i].parentesco = v),
                    validator: (v) => v == null ? 'Selecione' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: dependentes[i].data,
                    decoration: _dec('dd / mm / aaaa'),
                    keyboardType: TextInputType.datetime,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      brasil_fields.DataInputFormatter(),
                    ],
                    validator: (v) {
                      if (_required(v) != null) return 'Campo obrigatório';
                      final dt = _parseDate(v!.trim());
                      if (dt == null) return 'Data inválida';
                      if (dt.isAfter(DateTime.now())) return 'Não pode ser futura';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (i != dependentes.length - 1) const Divider(height: 24),
          ],
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _submit,
              child: const Text('ASSOCIE-SE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------- WIDGETS AUXILIARES -----------------
class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF0E1216).withOpacity(0.35),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _DepForm {
  final nome = TextEditingController();
  String? parentesco;
  final data = TextEditingController();
  void dispose() { nome.dispose(); data.dispose(); }
}

class _DepPreview extends StatelessWidget {
  const _DepPreview({
    required this.form,
    required this.parentescos,
    required this.dec,
  });

  final _DepForm form;
  final List<String> parentescos;
  final InputDecoration Function(String, {String? hint}) dec;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(controller: form.nome, decoration: dec('Nome do Dependente'), readOnly: true),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: form.parentesco, decoration: dec('Parentesco'),
                items: parentescos.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: form.data,
                decoration: dec('dd / mm / aaaa'),
                readOnly: true, // preview é só leitura
              ),
            ),
          ],
        ),
      ],
    );
  }
}
