import 'package:flutter/material.dart';

class BenefitDetailScreen extends StatelessWidget {
  final String category;
  final String badge;

  const BenefitDetailScreen(
      {super.key, required this.category, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: const Color(0xFF061A40),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Descontos em Saúde",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badge,
                    style: const TextStyle(color: Colors.white)),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Como utilizar",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("1. Apresente sua carteirinha digital do sindicato."),
          const Text("2. Leve documento com foto."),
          const Text("3. Solicite o desconto na recepção."),
          const SizedBox(height: 16),
          const Text(
            "Documentos necessários",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text("• Carteirinha do associado"),
          const Text("• Documento com foto"),
          const Text("• Comprovante de vínculo"),
          const SizedBox(height: 16),
          const Text(
            "Rede credenciada",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildClinicCard("Clínica Vida Bem",
              "Rua São Luiz, 120\nMarília, SP", context),
          _buildClinicCard(
              "Saúde Total Ourinhos", "Av. Brasil, 455", context),
        ],
      ),
    );
  }

  Widget _buildClinicCard(String name, String address, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(address),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call),
                  label: const Text("Ligar"),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat),
                  label: const Text("WhatsApp"),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map_outlined),
                  label: const Text("Ver no mapa"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
