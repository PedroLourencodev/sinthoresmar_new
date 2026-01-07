import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  static const String route = '/privacy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidade')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(_privacyText, textAlign: TextAlign.start),
        ),
      ),
    );
  }
}

const String _privacyText = r"""# Política de Privacidade — Sinthoresmar

**Última atualização:** 12 de novembro de 2025

Esta Política de Privacidade descreve como o Sinthoresmar coleta, usa e protege os seus dados pessoais ao utilizar o aplicativo **Sinthoresmar** (“Aplicativo”). Ao usar o Aplicativo, você concorda com esta Política.

---

## 1. Quem somos
O Sinthoresmar é um sindicato que oferece serviços como notícias, benefícios, FAQ, agendamento de consultoria jurídica, requisição digital de holerite e **denúncia anônima**. Somos responsáveis por tratar seus dados pessoais com transparência e segurança.

**Contato do responsável por privacidade:** contato@sinthoresmar.org.br

---

## 2. Bases legais e leis aplicáveis
Tratamos dados conforme a lei canadense **PIPEDA** (quando aplicável), e observamos boas práticas alinhadas ao **GDPR** (UE) para usuários de outras jurisdições. Para comunicação eletrônica, seguimos a **CASL** (lei anti‑spam do Canadá), exigindo consentimento para o envio de mensagens comerciais/push, com opção de descadastro a qualquer momento.

---

## 3. Dados coletados
Podemos coletar e tratar as seguintes informações:
- **Cadastro/Conta:** nome, e‑mail, telefone, número de matrícula/ID de associado (se houver), cargo/empresa/área (opcional).
- **Serviços do app:** dados fornecidos em formulários (ex.: agendamentos, solicitações de holerite, **denúncias anônimas**). Na denúncia anônima, **não exigimos identificação** e orientamos que você evite dados que permitam sua identificação, salvo se desejar.
- **Suporte e contato:** mensagens e anexos enviados pelo usuário.
- **Dados técnicos do dispositivo:** modelo do aparelho, sistema operacional, idioma, fuso horário, identificadores de notificação (push), logs de erros/uso.
- **Cookies/tecnologias similares (Web):** quando o app roda no navegador.

Não coletamos deliberadamente informações de crianças menores de 13 anos. Se você for responsável legal e acreditar que houve coleta indevida, fale conosco para exclusão.

---

## 4. Finalidades de uso
- **Prestação dos serviços** do Aplicativo (cadastro, autenticação, consultas, holerite, benefícios, notícias).
- **Atendimento e suporte.**
- **Segurança, prevenção a fraudes e abuso**, detecção e correção de erros.
- **Comunicações essenciais** sobre sua conta/serviços e **comunicações opcionais** (notícias, campanhas, avisos). Para comunicações comerciais, solicitamos **consentimento** (CASL) e você pode cancelar a qualquer momento.
- **Análises de uso** em nível agregado para melhoria do Aplicativo.

---

## 5. Compartilhamento de dados
Podemos compartilhar dados com:
- **Provedores de tecnologia** (por exemplo, hospedagem, autenticação, armazenamento em nuvem, e‑mail/Push). O Aplicativo utiliza serviços em nuvem (como **Supabase** e serviços equivalentes). Tais provedores processam dados **apenas** conforme nossas instruções contratuais.
- **Autoridades públicas** quando exigido por lei ou decisão judicial.
- **Terceiros** envolvidos na prestação de serviços do sindicato, sempre com necessidade e proteção adequadas.

Não vendemos dados pessoais.

---

## 6. Transferências internacionais
Dados podem ser processados fora do Canadá por nossos provedores de nuvem. Tomamos medidas contratuais e técnicas razoáveis para garantir um nível de proteção adequado e compatível com a **PIPEDA** e, quando aplicável, com o **GDPR**.

---

## 7. Retenção e segurança
- **Retenção:** mantemos os dados somente pelo tempo necessário para cumprir as finalidades declaradas e obrigações legais. Registros de **denúncia anônima** são mantidos com o mínimo de metadados possível.
- **Segurança:** adotamos controles técnicos e organizacionais (criptografia em trânsito, autenticação, controles de acesso, logs e backups). Nenhuma solução é 100% segura; em caso de incidente relevante, adotaremos medidas e comunicações exigidas.

---

## 8. Seus direitos
Dependendo da sua jurisdição, você pode ter direitos como **acesso, correção, atualização e exclusão** de dados, além de revogar consentimentos e **opt‑out** de comunicações. Para exercer, entre em contato em **contato@sinthoresmar.org.br**. Responderemos em prazo razoável conforme a lei aplicável.

---

## 9. Comunicações (CASL) e notificações
- Enviamos **mensagens essenciais** (ex.: avisos de conta/serviço).  
- **Mensagens promocionais** ou **push opcionais** são enviadas somente com **consentimento**. Você pode desativar nas configurações do app, do dispositivo ou por link de descadastro quando houver.

---

## 10. Política para crianças e adolescentes
O Aplicativo **não é destinado** a menores de 13 anos. Jovens acima dessa idade devem usar o Aplicativo com conhecimento dos responsáveis, quando exigido por lei local.

---

## 11. Alterações
Podemos atualizar esta Política para refletir mudanças no Aplicativo ou na lei. Publicaremos a versão revisada com data de vigência atualizada.

---

## 12. Contato
Dúvidas sobre privacidade? Fale com a gente: **contato@sinthoresmar.org.br**.
""";
