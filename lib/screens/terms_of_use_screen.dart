import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});
  static const String route = '/terms';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Termos de Uso')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(_termsText, textAlign: TextAlign.start),
        ),
      ),
    );
  }
}

const String _termsText = r"""# Termos de Uso — Sinthoresmar

**Última atualização:** 12 de novembro de 2025

Bem‑vindo(a)! Estes Termos regem o uso do aplicativo **Sinthoresmar** (“Aplicativo”). Ao utilizá‑lo, você concorda integralmente com estes Termos.

---

## 1. Objeto
O Aplicativo oferece funcionalidades como notícias, consulta a benefícios, FAQ, agendamento de consultoria jurídica, requisição digital de holerite e canal de **denúncia anônima**.

---

## 2. Conta do usuário
- Você deve fornecer informações verdadeiras e mantê‑las atualizadas.
- Guarde suas credenciais com segurança e **não compartilhe** sua senha.
- Atividades realizadas com sua conta presumem‑se feitas por você.

---

## 3. Uso aceitável
É proibido:
- Utilizar o Aplicativo para fins ilícitos ou violar direitos de terceiros.
- Enviar conteúdo ilegal, difamatório, discriminatório, obsceno, violento ou que viole privacidade.
- Tentar acessar áreas não autorizadas, explorar vulnerabilidades, burlar segurança ou sobrecarregar serviços.
- Coletar dados de outros usuários sem base legal e consentimento.

Podemos suspender ou encerrar contas que violem estes Termos.

---

## 4. Serviços e conteúdos
Empregamos esforços razoáveis para manter o Aplicativo disponível e atualizado, **sem garantias de disponibilidade contínua**. Conteúdos podem ser alterados, suspensos ou removidos a qualquer momento.

---

## 5. Denúncia anônima
O canal de **denúncia anônima** não exige identificação. Evite incluir dados que possam revelar sua identidade, salvo se desejar. Relatos falsos ou de má‑fé podem sujeitar o autor a medidas legais.

---

## 6. Comunicações
Podemos enviar mensagens **essenciais** sobre o uso do Aplicativo. Mensagens promocionais dependem de **consentimento** e podem ser canceladas (veja a Política de Privacidade).

---

## 7. Propriedade intelectual
O Sinthoresmar e/ou licenciantes detêm os direitos sobre marcas, logotipos, layout e software do Aplicativo. Você recebe uma **licença limitada, revogável e não exclusiva** para uso pessoal, nos termos aqui previstos.

---

## 8. Responsabilidade
Na extensão máxima permitida em lei, o Sinthoresmar não se responsabiliza por:
- Danos indiretos, incidentais, especiais ou consequenciais.
- Interrupções, falhas, bugs, vírus ou eventos fora do nosso controle razoável.
Nada exclui responsabilidade que não possa ser limitada por lei.

---

## 9. Links e terceiros
O Aplicativo pode conter links para serviços de terceiros (p.ex., provedores de nuvem). Não controlamos esses serviços e não nos responsabilizamos por seus conteúdos ou práticas.

---

## 10. Privacidade
O uso do Aplicativo também é regido pela **Política de Privacidade**. Leia-a cuidadosamente.

---

## 11. Alterações nos Termos
Podemos atualizar estes Termos. A versão vigente será publicada com data de atualização. O uso contínuo após a atualização implica concordância.

---

## 12. Legislação e foro
Estes Termos são regidos pelas leis do **Canadá** e da **Província de Ontário**, e eventuais disputas serão resolvidas nos tribunais competentes de Ontário, salvo disposições de ordem pública aplicáveis.

---

## 13. Contato
Dúvidas sobre estes Termos? **contato@sinthoresmar.org.br**.
""";
