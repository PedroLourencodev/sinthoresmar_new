import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// importa a tela de sucesso (mesma pasta "screens")
import 'requisicao_sucesso_screen.dart';

class RequisicaoHoleriteScreen extends StatefulWidget {
  const RequisicaoHoleriteScreen({super.key});

  @override
  State<RequisicaoHoleriteScreen> createState() => _RequisicaoHoleriteScreenState();
}

class _RequisicaoHoleriteScreenState extends State<RequisicaoHoleriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _cargoCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _empresaCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();

  final supabase = Supabase.instance.client;

Future<void> submitHolerite({
  required String nome,
  required String cpf,
  required String cargo,
  required String telefone,
  required String empresa,
  required String cidade,
  required String uf,
  required String competencia, // ex: "2025-08"
 }) async {
  final user = supabase.auth.currentUser;
  if (user == null) {
    // mostre um snackbar/alert
    return;
  }

  // 1) Seleciona o arquivo
  final picked = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    withData: true, // garante os bytes na memória
  );
  if (picked == null || picked.files.isEmpty) {
    // usuário cancelou
    return;
  }

  final file = picked.files.single;
  final Uint8List bytes = file.bytes!;
  final ext = (file.extension ?? 'pdf').toLowerCase();

  // 2) Monta o caminho no Storage
  final filename = '${competencia}_${DateTime.now().millisecondsSinceEpoch}.$ext';
  final storagePath = '${user.id}/$filename';

  // content-type simples por extensão
  String contentType = 'application/octet-stream';
  if (ext == 'pdf') contentType = 'application/pdf';
  if (ext == 'png') contentType = 'image/png';
  if (ext == 'jpg' || ext == 'jpeg') contentType = 'image/jpeg';

  // Faz upload
  final uploadRes = await supabase.storage
      .from('holerites')
      .uploadBinary(
        storagePath,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: contentType,
        ),
      );



  if (uploadRes.isEmpty) {
    // trate erro de upload se quiser (supabase_flutter retorna string/throw)
  }

  // 3) Insere o registro com file_path
  final insert = await supabase.from('holerite_requisicoes').insert({
    'user_id': user.id,
    'nome': nome,
    'cpf': cpf,
    'cargo': cargo,
    'telefone': telefone,
    'empresa': empresa,
    'cidade': cidade,
    'uf': uf,
     // 🔹 grava o caminho do arquivo que você acabou de subir
    'holerite_path': storagePath,   // campo que o painel lê
    'file_path'    : storagePath,   // opcional (back-compat)
    'file_url'     : null,          // se não usa URL pública, deixe null
    'competencia': competencia,
    'file_path': storagePath,  // 👈 **ESSENCIAL**
    'status': 'pending',
    'uploaded_at': DateTime.now().toIso8601String(), // opcional, mas útil


  });

  // opcional: tratar erro/limpar campos
}


  String? _uf;
  String? _beneficio;
  bool _concordoContato = false;
  bool _contatoEmail = false;
  bool _contatoTelefone = false;
  bool _lgpdOk = false;

  String? _uploadedName;
  String? _uploadedPath;
  String? _uploadedUrl;

  int? _reqId;
  String? _status; // 'pending' | 'approved' | 'rejected'
  String? _adminNotes;
  bool _loadingStatus = false;
  bool _sending = false;

  static const Color azulEscuro = Color(0xFF061A40);
  static const Color laranja    = Color(0xFFFF7F11);
  static const Color cinzaTxt   = Color(0xFF666666);

  final _ufs = const [
    'AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO'
  ];
  final _beneficios = const ['Convênio','Desconto','Assistência','Outro'];

  // Máscaras
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _telMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _fetchLatestRequestIfPossible();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _cargoCtrl.dispose();
    _telCtrl.dispose();
    _empresaCtrl.dispose();
    _cidadeCtrl.dispose();
    super.dispose();
  }

  // ----------------- Helpers -----------------
  String _onlyDigits(String s) => s.replaceAll(RegExp(r'\D'), '');

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      borderRadius: BorderRadius.circular(10),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.redAccent),
      borderRadius: BorderRadius.circular(10),
    ),
  );

  // ----------------- Data -----------------
  Future<void> _fetchLatestRequestIfPossible() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _loadingStatus = true);
    try {
      final data = await supabase
          .from('holerite_requisicoes')
          .select('id,status,admin_notes,holerite_path,created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        final path = data['holerite_path'] as String?;
        setState(() {
          _reqId        = (data['id'] as num?)?.toInt();
          _status       = data['status'] as String?;
          _adminNotes   = data['admin_notes'] as String?;
          _uploadedPath = path;
          _uploadedUrl  = (path != null)
              ? supabase.storage.from('holerites').getPublicUrl(path)
              : null;
          _uploadedName = path?.split('/').last;
        });
      }
    } catch (_) {
      // silencioso
    } finally {
      if (mounted) setState(() => _loadingStatus = false);
    }
  }

  Future<void> _pickAndUploadHolerite() async {
    final supabase = Supabase.instance.client;

    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf','jpg','jpeg','png'],
        withData: true,
      );
      if (res == null || res.files.isEmpty) return;

      final file = res.files.single;
      final String name = file.name;
      final Uint8List? bytes = file.bytes;
      if (bytes == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível ler o arquivo. Tente novamente.')),
        );
        return;
      }

      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anon';
      final ts = DateTime.now().toIso8601String().replaceAll(':', '').replaceAll('.', '');
      final path = '$userId/$ts-$name';

      await supabase.storage
          .from('holerites')
          .uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          contentType: _contentTypeFromName(name),
          upsert: true,
        ),
      );

      final publicUrl = supabase.storage.from('holerites').getPublicUrl(path);

      setState(() {
        _uploadedName = name;
        _uploadedPath = path;
        _uploadedUrl  = publicUrl;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Holerite enviado com sucesso!')),
      );
    } on StorageException catch (e) {
      debugPrint('Storage upload error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha no upload: ${e.message}')),
      );
    } catch (e) {
      debugPrint('Storage upload unknown error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado ao enviar.')),
      );
    }
  }

  Future<void> _resendDocument() async {
    await _pickAndUploadHolerite();
    final supabase = Supabase.instance.client;

    final reqId = _reqId;
    final uploadedPath = _uploadedPath;

    if (reqId == null || uploadedPath == null) return;

    try {
     await supabase
         .from('holerite_requisicoes')
         .update({
           'holerite_path': uploadedPath,           // caminho novo do arquivo
           'file_path'    : uploadedPath,           // garante que o painel habilite "Ver"
           'file_url'     : null,                   // se não usa URL pública, deixe null
           'status'       : 'pending',              // volta para análise
           'reviewed_at'  : null,                   // limpa revisão anterior
           'uploaded_at'  : DateTime.now().toIso8601String(), // opcional, mas útil
         })
         .eq('id', reqId);
      setState(() => _status = 'pending');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento reenviado! Sua solicitação voltou para análise.')),
        );
      }
    } catch (e) {
      debugPrint('DB update error (resend): $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar a requisição.')),
      );
    }
  }

  String _contentTypeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    return 'application/octet-stream';
  }

  // ----------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    final canSend = _lgpdOk && _uploadedPath != null && !_sending;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identificação do Associado'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar status',
            onPressed: _fetchLatestRequestIfPossible,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_buildStatusBanner() != null) ...[
                _buildStatusBanner()!,
                const SizedBox(height: 12),
              ],

              const Text('Identificação do Associado', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nomeCtrl,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: _dec('Nome completo'),
                      validator: (v) => (v == null || v.trim().length < 3) ? 'Informe seu nome completo' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _cpfCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_cpfMask, LengthLimitingTextInputFormatter(14)],
                      textInputAction: TextInputAction.next,
                      decoration: _dec('CPF'),
                      // valida apenas 11 dígitos
                      validator: (v) {
                        final digits = _onlyDigits(v ?? '');
                        return digits.length == 11 ? null : 'CPF inválido';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _cargoCtrl,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: _dec('Cargo'),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _telCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [_telMask, LengthLimitingTextInputFormatter(16)],
                textInputAction: TextInputAction.next,
                decoration: _dec('Telefone/WhatsApp'),
                validator: (v) {
                  final digits = _onlyDigits(v ?? '');
                  return (digits.length == 11 || digits.length == 10) ? null : 'Telefone inválido';
                },
              ),

              const SizedBox(height: 16),
              const Text('Comprovação de Associação (Holerite)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _empresaCtrl,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: _dec('Empresa atual'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a empresa' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cidadeCtrl,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: _dec('Cidade'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a cidade' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _uf,
                      items: _ufs.map((uf) => DropdownMenuItem(value: uf, child: Text(uf))).toList(),
                      onChanged: (v) => setState(() => _uf = v),
                      decoration: _dec('UF'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Selecione a UF' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Botão "Enviar último holerite"
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file_outlined, color: laranja),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Enviar último holerite', style: TextStyle(fontWeight: FontWeight.w700, color: laranja)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: laranja),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: const Color(0xFFFFF2E6),
                  ),
                 onPressed: () async {
                   await submitHolerite(
                     nome: _nomeCtrl.text,
                     cpf: _cpfCtrl.text,
                     cargo: _cargoCtrl.text,
                     telefone: _telCtrl.text,
                     empresa: _empresaCtrl.text,
                     cidade: _cidadeCtrl.text,
                     uf: _uf ?? '',
                     competencia: DateFormat('yyyy-MM').format(DateTime.now()),
                   );

                   // opcional: limpar os campos após envio
                   _nomeCtrl.clear();
                   _cpfCtrl.clear();
                   _cargoCtrl.clear();
                   _telCtrl.clear();
                   _empresaCtrl.clear();
                   _cidadeCtrl.clear();
                   setState(() {
                     _uf = null;
                   });
                 },
                ),
              ),
              if (_uploadedName != null) ...[
                const SizedBox(height: 6),
                Text('Arquivo: $_uploadedName', style: const TextStyle(color: cinzaTxt, fontSize: 12)),
                if (_uploadedUrl != null)
                  TextButton.icon(
                    onPressed: () => launchUrlString(_uploadedUrl!),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Abrir documento'),
                  ),
              ],

              const SizedBox(height: 10),
              const Text(
                'Confirmo que o documento enviado é meu e autorizo o uso exclusivo para verificar contribuição sindical.',
                style: TextStyle(fontSize: 12, color: cinzaTxt, height: 1.2),
              ),

              const SizedBox(height: 16),
              const Text('Estabelecimento e Benefício Solicitado', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _beneficio,
                hint: const Text('Benefício'),
                items: _beneficios.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setState(() => _beneficio = v),
                decoration: _dec('Benefício'),
                validator: (v) => (v == null || v.isEmpty) ? 'Selecione o benefício' : null,
              ),

              const SizedBox(height: 16),
              const Text('Local (cidade/UF) do estabelecimento', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),

              Row(
                children: [
                  Checkbox(
                    value: _concordoContato,
                    onChanged: (v) => setState(() => _concordoContato = v ?? false),
                  ),
                  const Text('Li e concordo ser contatado?'),
                  const SizedBox(width: 10),
                  FilterChip(
                    label: const Text('E-mail'),
                    selected: _contatoEmail,
                    onSelected: _concordoContato ? (v) => setState(() => _contatoEmail = v) : null,
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Telefone'),
                    selected: _contatoTelefone,
                    onSelected: _concordoContato ? (v) => setState(() => _contatoTelefone = v) : null,
                  ),
                ],
              ),

              Row(
                children: [
                  Checkbox(value: _lgpdOk, onChanged: (v) => setState(() => _lgpdOk = v ?? false)),
                  const Expanded(
                    child: Text('Li e concordo com o tratamento dos meus dados para análise da requisição, conforme a LGPD.', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canSend ? _submitRequest : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: laranja,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _sending
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Concluir e enviar', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildStatusBanner() {
    if (_status == null) return null;

    Color bg;
    Color fg = Colors.black87;
    IconData icon;
    String title;
    String? desc;
    List<Widget> actions = [];

    switch (_status) {
      case 'approved':
        bg = const Color(0xFFE8F5E9);
        icon = Icons.verified_user_outlined;
        title = 'Identificação confirmada!';
        desc  = 'Você já pode usar o benefício.';
        break;
      case 'rejected':
        bg = const Color(0xFFFFEBEE);
        icon = Icons.error_outline;
        title = 'Documento reprovado';
        desc  = _adminNotes ?? 'Envie novamente seu holerite.';
        actions = [
          TextButton.icon(
            onPressed: _resendDocument,
            icon: const Icon(Icons.upload_file),
            label: const Text('Enviar novamente'),
          ),
        ];
        break;
      default:
        bg = const Color(0xFFFFFDE7);
        icon = Icons.hourglass_top_outlined;
        title = 'Sua solicitação está em análise';
        desc  = 'Fique de olho nas atualizações.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (desc != null) ...[
                  const SizedBox(height: 4),
                  Text(desc!, style: TextStyle(color: fg)),
                ],
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: actions),
                ]
              ],
            ),
          ),
          if (_loadingStatus)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Corrija os campos destacados.')),
      );
      return;
    }
    if (_uploadedPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Envie o holerite antes de concluir.')),
      );
      return;
    }

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    final payload = {
      'user_id': userId,
      'nome': _nomeCtrl.text.trim(),
      'cpf': _cpfCtrl.text.trim(),
      'cargo': _cargoCtrl.text.trim(),
      'telefone': _telCtrl.text.trim(),
      'empresa': _empresaCtrl.text.trim(),
      'cidade': _cidadeCtrl.text.trim(),
      'uf': _uf,
      'beneficio': _beneficio,
      'contato_email': _contatoEmail,
      'contato_telefone': _contatoTelefone,
      'holerite_path': _uploadedPath,
      // 'holerite_url_public': _uploadedUrl,
      // sem created_at: db preenche
    };

    setState(() => _sending = true);
    try {
      // Insert simples (sem select) para não depender de policy de SELECT
      await supabase.from('holerite_requisicoes').insert(payload);

      if (!mounted) return;
      // Navega para a tela de sucesso sem precisar de rota nomeada
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RequisicaoSucessoScreen()),
      );
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException: ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar: ${e.message}')),
      );
    } catch (e) {
      debugPrint('DB insert error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível enviar a requisição.')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}
