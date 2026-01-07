import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news.dart';

class NewsService {
  NewsService._();
  static final NewsService instance = NewsService._();

  final _sb = Supabase.instance.client;

  Future<List<News>> fetchLatest({int limit = 20}) async {
    final rows = await _sb
         .from('news')
         .select('id, title, subtitle, content, image_url, is_published, created_at, published_at')
         .eq('is_published', true)
         .order('published_at', ascending: false)
         .limit(limit);


    if (rows is List) {
      return rows
          .map((e) => News.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Stream<List<News>> streamNews({int limit = 50}) {
    return _sb
        .from('news')
        .stream(primaryKey: ['id'])
        .eq('is_published', true)
        .order('published_at', ascending: false) // sem nullsFirst
        .limit(limit)
        .map((rows) =>
        rows.map((e) => News.fromMap(Map<String, dynamic>.from(e))).toList());
  }
}
