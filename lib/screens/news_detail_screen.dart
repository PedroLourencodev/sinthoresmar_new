import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/news.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.news});

  final News news;

  static const Color azulEscuro = Color(0xFF061A40);
  static const Color cinzaTexto = Color(0xFF666666);

  String _fmtDate(DateTime dt) {
    return DateFormat('dd/MM/yyyy • HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final dt = news.publishedAt ?? news.createdAt;
    final img = news.imageUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: azulEscuro,
        title: const Text('Detalhe da Notícia'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (img != null && img.isNotEmpty)
            Image.network(
              img,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: const Color(0xFFEDEFF3),
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined, size: 40),
              ),
            )
          else
            Container(
              height: 220,
              color: const Color(0xFFEDEFF3),
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported_outlined, size: 40),
            ),

          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: azulEscuro,
                  ),
                ),

                // 👇 Adiciona aqui o subtítulo
                if ((news.subtitle ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      news.subtitle!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: cinzaTexto),
                    const SizedBox(width: 6),
                    Text(
                      _fmtDate(dt),
                      style: const TextStyle(fontSize: 13, color: cinzaTexto),
                    ),
                  ],
                ),

                if ((news.content ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      news.content!,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      )
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Sem conteúdo adicional.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
