import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// telas principais
import 'screens/home_screen.dart';
import 'screens/services_screen.dart';
import 'screens/benefits_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/terms_of_use_screen.dart';
import 'screens/privacy_policy_screen.dart';

// cadastro
import 'screens/associe_se_screen.dart';

// demais telas
import 'screens/faq_screen.dart';
import 'screens/agendar_consultoria_screen.dart';
import 'screens/requisicao_holerite_screen.dart';
import 'screens/calculo_trabalhista_screen.dart';
import 'screens/denuncia_anonima_screen.dart';

// ===============================================================
// FUNÇÃO PRINCIPAL (main)
// ===============================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://epeubhlsxqvwmekardwz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwZXViaGxzeHF2d21la2FyZHd6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1NTk0NDMsImV4cCI6MjA3MTEzNTQ0M30.Y_xV0nvzw4YRuEzprilFzmrskabqMYb9fu-fJZz5U0g',
  );

  runApp(const SinthoresmarApp());
}

// ===============================================================
// APP PRINCIPAL
// ===============================================================
class SinthoresmarApp extends StatefulWidget {
  const SinthoresmarApp({super.key});

  // atalhos úteis para navegação
  static void goHome(BuildContext context) {
    final state = context.findAncestorStateOfType<_SinthoresmarAppState>();
    state?._setTab(0);
  }

  static void goToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_SinthoresmarAppState>();
    state?._setTab(index);
  }

  @override
  State<SinthoresmarApp> createState() => _SinthoresmarAppState();
}

class _SinthoresmarAppState extends State<SinthoresmarApp> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      ServicesScreen(onBackToHome: () => _setTab(0)),
      BenefitsHomeScreen(onBackToHome: () => _setTab(0)),
      ContactsScreen(onBackToHome: () => _setTab(0)),
    ];
  }

  void _setTab(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);
  }

  Future<bool> _handleSystemBack() async {
    if (_currentIndex != 0) {
      _setTab(0);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SINTHORESMAR',
      theme: buildTheme(),

      // Localização BR
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Scaffold com controle de abas e back físico
      home: WillPopScope(
        onWillPop: _handleSystemBack,
        child: Scaffold(
          body: _pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _setTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFFFF3B30),
            unselectedItemColor: const Color(0xFF555555),
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.handyman_outlined),
                label: 'Serviços',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.card_giftcard),
                label: 'Benefícios',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.contact_phone_outlined),
                label: 'Contatos',
              ),
            ],
          ),
        ),
      ),

      // Rotas nomeadas
      routes: {
        ProfileScreen.route:    (_) => const ProfileScreen(),
        LoginScreen.route:      (_) => const LoginScreen(),
        AssocieSeScreen.route:  (_) => const AssocieSeScreen(),
        '/register':            (_) => const AssocieSeScreen(),
        '/terms':               (_) => const TermsOfUseScreen(),
        '/privacy':             (_) => const PrivacyPolicyScreen(),
        '/faq':                 (_) => const FaqScreen(),
        '/agendamento':         (_) => const AgendarConsultoriaScreen(),
        '/holerite':            (_) => const RequisicaoHoleriteScreen(),
        '/calculo':             (_) => const CalculoTrabalhistaScreen(),
        '/denuncia':            (_) => const DenunciaAnonimaScreen(),
      },
    );
  }
}
