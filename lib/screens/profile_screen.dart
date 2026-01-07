import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const route = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ===== Header com logo + SINTHORESMAR =====
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/sinthoresmar_logo.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'SINTHORESMAR',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?q=80&w=800&auto=format&fit=crop',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'João Silva',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Meu Perfil'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
