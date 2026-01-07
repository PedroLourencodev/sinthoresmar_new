import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

/// Insere barras automaticamente para dd/mm/aaaa
class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var t = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (t.length > 8) t = t.substring(0, 8);

    String withSlashes = '';
    for (int i = 0; i < t.length; i++) {
      withSlashes += t[i];
      if (i == 1 || i == 3) withSlashes += '/';
    }

    return TextEditingValue(
      text: withSlashes,
      selection: TextSelection.collapsed(offset: withSlashes.length),
    );
  }
}

/// Struct simples para anos/meses
class AnosMeses {
  final int anos;
  final int meses;
  const AnosMeses(this.anos, this.meses);
}

class CalculoTrabalhistaScreen extends StatefulWidget {
  const CalculoTrabalhistaScreen({super.key});
  static const String route = '/calculo_trabalhista';

  @override
  State<CalculoTrabalhistaScreen> createState() =>
      _CalculoTrabalhistaScreenState();
}

class _CalculoTrabalhistaScreenState extends State<CalculoTrabalhistaScreen> {
  // Cores
  static const Color azulEscuro = Color(0xFF061A40);
  static const Color laranja = Color(0xFFFF7F11);

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _salarioCtrl = TextEditingController();
  final _admissaoCtrl = TextEditingController();
  final _demissaoCtrl = TextEditingController();
  final _diasMesCtrl = TextEditingController();
  final _horasExtrasCtrl = TextEditingController();
  final _fgtsSaldoCtrl =
  TextEditingController(); // saldo FGTS (extrato) opcional

  // Resultados
  double saldoSalario = 0;
  double avisoPrevio = 0;
  double decimoTerceiro = 0;
  double feriasVencidas = 0;
  double feriasProporcionais = 0;
  double multaFgts40 = 0;
  double horasExtras100 = 0;
  double totalGeral = 0;

  bool mostrarResultados = false;

  // Flags de UI
  bool _fgtsUsouEstimativa = false; // para exibir badge

  // Seletores
  String _motivoDispensa =
      'sem_justa_causa'; // 'sem_justa_causa' | 'pedido_demissao'
  Set<String> _motivoSelecionado = {'sem_justa_causa'};

  String _avisoTipo = 'trabalhado'; // 'trabalhado' | 'indenizado'
  Set<String> _avisoTipoSelecionado = {'trabalhado'};

  bool _temFeriasVencidas = false;
  Set<bool> _feriasVencidasSelecionado = {false};

  // Tempo de casa
  int anosTrabalhoCalc = 0;
  int mesesRestantesCalc = 0;

  String get tempoDeCasaStr {
    final a = anosTrabalhoCalc;
    final m = mesesRestantesCalc;
    final pa = a == 1 ? 'ano' : 'anos';
    final pm = m == 1 ? 'mês' : 'meses';
    if (a == 0) return '$m $pm';
    if (m == 0) return '$a $pa';
    return '$a $pa e $m $pm';
  }

  // ---------- Fórmulas ----------
  double _calcSaldoSalario(double salario, int dias) => (salario / 30) * dias;

  double _calc13(double salario, int mesesAno) => (salario / 12) * mesesAno;

  double _calcFeriasVencidas(double salario, int periodos) =>
      periodos > 0 ? salario + (salario / 3) : 0;

  double _calcFeriasProporcionais(double salario, int mesesAno) {
    final base = (salario / 12) * mesesAno;
    return base + (base / 3);
  }

  double _calcHorasExtras(double salario, double qtdHoras) {
    final valorHora = salario / 220; // jornada 44h/semana
    return qtdHoras * valorHora * 2.0; // 100% (dobro)
  }

  String _moeda(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  // Lê "R$ 1.234,56" e converte para 1234.56
  double _parseMoeda(String text) {
    final onlyDigits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.isEmpty) return 0.0;
    return double.parse(onlyDigits) / 100.0;
  }

  // ---------- Utils de Data ----------
  DateTime? _parseDate(String input) {
    try {
      final p = input.trim().split('/');
      if (p.length != 3) return null;
      final d = int.parse(p[0]);
      final m = int.parse(p[1]);
      final y = int.parse(p[2]);
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString().padLeft(4, '0');
    return '$dd/$mm/$yyyy';
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1970, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      builder: (ctx, child) {
        return Localizations.override(
          context: ctx,
          locale: const Locale('pt', 'BR'),
          child: Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: laranja,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      controller.text = _fmtDate(picked);
    }
  }

  /// meses inteiros + regra dos 15 dias no último mês
  int _diffMonthsInclusive(DateTime a, DateTime b) {
    if (!b.isAfter(a)) return 0;
    int months = (b.year - a.year) * 12 + (b.month - a.month);
    final lastMonthStart = DateTime(b.year, b.month, 1);
    final workedDaysLastMonth = b.difference(lastMonthStart).inDays + 1;
    if (workedDaysLastMonth >= 15) months++;
    return months;
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;

    // Salário em R$ formatado (R$ 1.234,56 -> 1234.56)
    final salario = _parseMoeda(_salarioCtrl.text);

    final adm = _parseDate(_admissaoCtrl.text);
    final dem = _parseDate(_demissaoCtrl.text);

    if (adm == null || dem == null || !dem.isAfter(adm)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Datas inválidas. Use dd/mm/aaaa e verifique se a demissão é depois da admissão.',
          ),
        ),
      );
      return;
    }

    final diasTrabalhadosMes = int.parse(_diasMesCtrl.text);
    final horasExtrasQtd = double.tryParse(
        _horasExtrasCtrl.text.trim().replaceAll(',', '.')) ??
        0.0;

    final String saldoFgtsText = _fgtsSaldoCtrl.text.trim();
    final double? saldoFgtsInformado =
    saldoFgtsText.isEmpty ? null : _parseMoeda(saldoFgtsText);

    // Tempo de casa
    final mesesTotais = _diffMonthsInclusive(adm, dem);
    final anos = mesesTotais ~/ 12;
    final meses = mesesTotais % 12;
    anosTrabalhoCalc = anos;
    mesesRestantesCalc = meses;

    // Meses válidos para 13º no ano da demissão
    final mesesPara13 = _diffMonthsInclusive(
      (adm.year == dem.year) ? adm : DateTime(dem.year, 1, 1),
      dem,
    );

    // Cálculos base
    saldoSalario = _calcSaldoSalario(salario, diasTrabalhadosMes);
    decimoTerceiro = _calc13(salario, mesesPara13);
    feriasVencidas =
    _temFeriasVencidas ? _calcFeriasVencidas(salario, 1) : 0.0;
    feriasProporcionais = _calcFeriasProporcionais(salario, mesesPara13);
    horasExtras100 = _calcHorasExtras(salario, horasExtrasQtd);

    // Multa FGTS 40% (oficial com extrato, senão estimativa com 13º)
    if (_motivoDispensa == 'sem_justa_causa') {
      if (saldoFgtsInformado != null && saldoFgtsInformado > 0) {
        multaFgts40 = saldoFgtsInformado * 0.40;
        _fgtsUsouEstimativa = false;
      } else {
        final estimDepositos =
            (salario * 0.08 * mesesTotais) + (decimoTerceiro * 0.08);
        multaFgts40 = estimDepositos * 0.40;
        _fgtsUsouEstimativa = true;
      }
    } else {
      multaFgts40 = 0.0;
      _fgtsUsouEstimativa = false;
    }

    // Aviso Prévio – Lei 12.506/2011
    final diasAvisoLei12506 = (30 + anos * 3).clamp(30, 90);
    if (_motivoDispensa == 'sem_justa_causa') {
      if (_avisoTipo == 'indenizado') {
        avisoPrevio = (salario / 30) * diasAvisoLei12506; // paga ao empregado
      } else {
        avisoPrevio = 0.0;
      }
    } else {
      if (_avisoTipo == 'indenizado') {
        avisoPrevio = -(salario / 30) * 30; // desconto até 30 dias
      } else {
        avisoPrevio = 0.0;
      }
    }

    totalGeral = saldoSalario +
        avisoPrevio +
        decimoTerceiro +
        feriasVencidas +
        feriasProporcionais +
        horasExtras100 +
        multaFgts40;

    setState(() => mostrarResultados = true);
  }

  // Decorações
  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.black12),
    ),
  );

  // Mesma base, com ícone de informação (tooltip) opcional
  InputDecoration _decInfo(String hint, {required String tooltip}) =>
      _dec(hint).copyWith(
        suffixIcon: Tooltip(
          message:
          '$tooltip\n\nSe deixar em branco, a multa será estimada (8% dos meses + 8% do 13º).',
          triggerMode: TooltipTriggerMode.longPress,
          child: const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.info_outline),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulEscuro,
      appBar: AppBar(
        backgroundColor: azulEscuro,
        elevation: 0,
        centerTitle: true,
        title: const Text('Cálculo Trabalhista'),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Campos principais
                      TextFormField(
                        controller: _salarioCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          CurrencyTextInputFormatter.currency(
                            locale: 'pt_BR',
                            decimalDigits: 2,
                            symbol: 'R\$',
                          ),
                        ],
                        decoration: _dec('Salário mensal'),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Informe o salário'
                            : null,
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _admissaoCtrl,
                        readOnly: true,
                        onTap: () => _pickDate(_admissaoCtrl),
                        keyboardType: TextInputType.number,
                        inputFormatters: [DateTextFormatter()],
                        decoration: _dec('Data de Admissão'),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Informe a data de admissão';
                          }
                          return _parseDate(v) == null
                              ? 'Data inválida (dd/mm/aaaa)'
                              : null;
                        },
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _demissaoCtrl,
                        readOnly: true,
                        onTap: () => _pickDate(_demissaoCtrl),
                        keyboardType: TextInputType.number,
                        inputFormatters: [DateTextFormatter()],
                        decoration: _dec('Data de Demissão'),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Informe a data de demissão';
                          }
                          final d = _parseDate(v);
                          if (d == null) return 'Data inválida (dd/mm/aaaa)';
                          final a = _parseDate(_admissaoCtrl.text);
                          if (a != null && !d.isAfter(a)) {
                            return 'Demissão deve ser após a admissão';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _diasMesCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _dec('Dias trabalhados no mês'),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Informe os dias trabalhados'
                            : null,
                      ),
                      const SizedBox(height: 10),

                      // Horas Extras 100% (quantidade)
                      TextFormField(
                        controller: _horasExtrasCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                        _dec('Horas Extras (100%) - quantidade'),
                      ),
                      const SizedBox(height: 10),

                      // Saldo FGTS (extrato) — opcional (com tooltip)
                      TextFormField(
                        controller: _fgtsSaldoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          CurrencyTextInputFormatter.currency(
                            locale: 'pt_BR',
                            decimalDigits: 2,
                            symbol: 'R\$',
                          ),
                        ],
                        decoration: _decInfo(
                          'Saldo FGTS (extrato) — opcional',
                          tooltip:
                          'Informe o saldo exato do extrato FGTS para calcular a multa de 40% com precisão.',
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Motivo da dispensa — TÍTULO
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Motivo da dispensa',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Motivo da dispensa — BOTÕES
                      InputDecorator(
                        decoration: _dec(''),
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'sem_justa_causa',
                              label: Text('Dispensa sem justa causa'),
                              icon: Icon(Icons.gavel_outlined),
                            ),
                            ButtonSegment<String>(
                              value: 'pedido_demissao',
                              label: Text('Pedido de demissão'),
                              icon: Icon(Icons.logout_outlined),
                            ),
                          ],
                          selected: _motivoSelecionado,
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              _motivoSelecionado = newSelection;
                              _motivoDispensa = _motivoSelecionado.first;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Férias vencida — TÍTULO
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Férias vencida',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Férias vencida — BOTÕES
                      InputDecorator(
                        decoration: _dec(''),
                        child: SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Sim'),
                              icon: Icon(Icons.check_circle_outline),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('Não'),
                              icon: Icon(Icons.cancel_outlined),
                            ),
                          ],
                          selected: _feriasVencidasSelecionado,
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              _feriasVencidasSelecionado = newSelection;
                              _temFeriasVencidas =
                                  _feriasVencidasSelecionado.first;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Aviso prévio — TÍTULO
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Aviso prévio',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Aviso prévio — BOTÕES
                      InputDecorator(
                        decoration: _dec(''),
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'trabalhado',
                              label: Text('Trabalhado'),
                              icon: Icon(Icons.work_outline),
                            ),
                            ButtonSegment<String>(
                              value: 'indenizado',
                              label: Text('Indenizado '),
                              icon:
                              Icon(Icons.money_off_csred_outlined),
                            ),
                          ],
                          selected: _avisoTipoSelecionado,
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              _avisoTipoSelecionado = newSelection;
                              _avisoTipo = _avisoTipoSelecionado.first;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botão calcular
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: laranja,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _calcular,
                          child: const Text(
                            'CALCULAR',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                if (mostrarResultados) ...[
                  Text(
                    'Resultados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: azulEscuro,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // BADGE sobre FGTS (apenas quando há multa: sem justa causa)
                  if (_motivoDispensa == 'sem_justa_causa')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _fgtsUsouEstimativa
                          ? _badge(
                        text:
                        'Multa do FGTS calculada por ESTIMATIVA (8% dos meses + 8% do 13º). '
                            'Para o valor EXATO, informe o saldo do extrato.',
                        warning: true,
                      )
                          : _badge(
                        text:
                        'Multa do FGTS calculada sobre o SALDO informado do extrato (cálculo oficial).',
                        warning: false,
                      ),
                    ),

                  _linha('Tempo de casa', tempoDeCasaStr),
                  _linha('Saldo de Salário', _moeda(saldoSalario)),
                  _linha('Aviso Prévio', _moeda(avisoPrevio)),
                  _linha('13º Proporcional', _moeda(decimoTerceiro)),
                  _linha(
                    'Férias vencida',
                    _temFeriasVencidas
                        ? _moeda(feriasVencidas)
                        : 'Não aplicável',
                  ),
                  _linha('Férias Proporcionais',
                      _moeda(feriasProporcionais)),
                  _linha('Horas Extras (100%)',
                      _moeda(horasExtras100)),
                  _linha('Multa FGTS (40%)', _moeda(multaFgts40)),
                  const Divider(height: 24),
                  _linha('Total Geral', _moeda(totalGeral),
                      negrito: true),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Badge reutilizável (warning/ok)
  Widget _badge({required String text, required bool warning}) {
    final bg =
    warning ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);
    final bd =
    warning ? const Color(0xFFFFCC80) : const Color(0xFF81C784);
    final ic =
    warning ? Icons.warning_amber_rounded : Icons.check_circle;
    final icColor =
    warning ? const Color(0xFFFF8F00) : const Color(0xFF2E7D32);
    final txColor =
    warning ? const Color(0xFF5D4037) : const Color(0xFF1B5E20);
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bd),
      ),
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ic, color: icColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: txColor,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linha(String titulo, String valor, {bool negrito = false}) {
    final estilo = TextStyle(
      fontSize: 16,
      fontWeight: negrito ? FontWeight.w800 : FontWeight.w600,
      color: Colors.black87,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(titulo, style: estilo)),
          Text(valor, style: estilo),
        ],
      ),
    );
  }
}
