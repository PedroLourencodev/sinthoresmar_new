class News {
  final String id;              // Aceita int/uuid, mas guardamos como String
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? content;
  final DateTime createdAt;     // Fallback se não existir no DB
  final bool isPublished;
  final DateTime? publishedAt;

  const News({
    required this.id,
    required this.title,
    this.subtitle,          // 👈 novo
    this.imageUrl,
    this.content,
    required this.createdAt,
    required this.isPublished,
    this.publishedAt,
  });

  // Helpers de parsing seguros
  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
    // Se o Supabase retornar timestamp como número (raro no Flutter), trate aqui.
  }

  static bool _parseBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is int) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      return s == 'true' || s == '1' || s == 't';
    }
    return false;
  }

  factory News.fromMap(Map<String, dynamic> m) {
    final pubAt = _parseDate(m['published_at']);
    final crtAt = _parseDate(m['created_at']) ?? pubAt ?? DateTime.now();

    return News(
      id: (m['id'] ?? '').toString(),                // <-- se vier int, vira "14"
      title: (m['title'] ?? '').toString(),
      subtitle: (m['subtitle'] as String?),
      imageUrl: (m['image_url'] as String?),
      content: (m['content'] as String?),
      createdAt: crtAt,
      isPublished: _parseBool(m['is_published']),
      publishedAt: pubAt,
    );
  }
}
