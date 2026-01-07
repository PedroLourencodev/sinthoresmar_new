import 'package:flutter/material.dart';
import 'benefit_detail_screen.dart';

class BenefitsListScreen extends StatelessWidget {
  const BenefitsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todos os Benefícios"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "🎁 Seus Benefícios",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),
          const Text(
            "Descubra todos os benefícios exclusivos disponíveis para você e sua família.",
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: "Buscar benefícios...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF2F2F2),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          _buildCategory(context, "Clínicas Médicas", "Até 30% OFF",
              "Acesso a clínicas médicas com preços diferenciados"),
          _buildCategory(context, "Laboratórios de Análises", "Até 25% OFF",
              "Descontos em exames laboratoriais"),
          _buildCategory(context, "Farmácias", "Até 15% OFF",
              "Medicamentos com desconto"),
          _buildCategory(context, "Odontologia", "Até 40% OFF",
              "Tratamentos odontológicos com valores especiais"),
        ],
      ),
    );
  }

  Widget _buildCategory(
      BuildContext context, String title, String badge, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            badge,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BenefitDetailScreen(
                category: title,
                badge: badge,
              ),
            ),
          );
        },
      ),
    );
  }
}
