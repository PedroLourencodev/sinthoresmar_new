import 'package:flutter/material.dart';

class RequisicaoSucessoScreen extends StatelessWidget {
  const RequisicaoSucessoScreen({super.key});

  static const Color azulEscuro = Color(0xFF061A40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulEscuro,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Requisição',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // volta aos Serviços
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 28),

              // Círculo verde com check
              Container(
                width: 108,
                height: 108,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 64),
              ),

              const SizedBox(height: 24),

              const Text(
                'Identificação enviada\ncom sucesso',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A0A0A),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Recebemos sua solicitação. Você será contatado por WhatsApp ou e-mail em até 7 dias úteis informando se o documento foi aprovado ou não.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Color(0xFF505050),
                ),
              ),

              const Spacer(),

              // Botão Voltar aos Serviços
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFFF7F7F7),
                  ),
                  child: const Text(
                    'Voltar aos Serviços',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: azulEscuro,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Rodapé com prazo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.access_time, size: 18, color: Color(0xFF606060)),
                  SizedBox(width: 6),
                  Text(
                    'Est. prazo: até 7 dias úteis',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF606060),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
