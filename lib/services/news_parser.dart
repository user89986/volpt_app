// lib/services/news_parser.dart
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import '../models/news_model.dart';

class NewsParser {
  static const String baseUrl = 'https://volpt.ru';

  static Future<List<NewsItem>> fetchNews() async {
    try {
      print('🔄 Пытаемся подключиться к $baseUrl');
      
      final client = http.Client();
      final response = await client.get(
        Uri.parse(baseUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 Статус ответа: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Успешное подключение, начинаем парсинг КАРУСЕЛИ НОВОСТЕЙ');
        return _parseVolptNews(response.body);
      } else {
        throw Exception('Сайт вернул ошибку: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Ошибка подключения: $e');
      rethrow;
    }
  }

  static List<NewsItem> _parseVolptNews(String html) {
    final document = parser.parse(html);
    final newsItems = <NewsItem>[];

    print('🔍 Ищем карусель новостей...');

    // Ищем карусель новостей
    final carousel = document.querySelector('.carousel .viewport');
    
    if (carousel == null) {
      print('❌ Карусель новостей не найдена!');
      return _fallbackParseNews(document);
    }

    print('✅ Найдена карусель новостей, извлекаем элементы...');

    // Ищем все ссылки с новостями в карусели
    final newsLinks = carousel.querySelectorAll('a[href*="volpt.ru"]');
    print('📰 Найдено новостных ссылок: ${newsLinks.length}');

    for (var link in newsLinks) {
      try {
        final href = link.attributes['href']?.trim();
        if (href == null || href.isEmpty) continue;

        // Извлекаем дату
        final dateElement = link.querySelector('p.info');
        final date = dateElement?.text?.trim() ?? '';

        // Извлекаем заголовок
        final titleElement = link.querySelector('p.title');
        final title = titleElement?.text?.trim() ?? '';

        // Извлекаем описание
        final descriptionElement = link.querySelector('p[style*="color: #555"]');
        final description = descriptionElement?.text?.trim() ?? '';

        // Извлекаем картинку
        final imageElement = link.querySelector('.thumbnail img');
        final imageUrl = imageElement?.attributes['src'];

        // Проверяем, что это действительно новость (есть дата и заголовок)
        if (date.isNotEmpty && title.isNotEmpty) {
          newsItems.add(NewsItem(
            title: title,
            description: _cleanDescription(description),
            date: date,
            imageUrl: imageUrl != null ? _makeAbsoluteUrl(imageUrl) : null,
            link: _makeAbsoluteUrl(href),
          ));
          
          print('✅ Найдена новость: "$title" ($date)');
        }
      } catch (e) {
        print('⚠️ Ошибка парсинга новости: $e');
      }
    }

    // Если в карусели не нашли, пробуем альтернативные методы
    if (newsItems.isEmpty) {
      print('⚠️ В карусели новости не найдены, используем альтернативные методы...');
      return _fallbackParseNews(document);
    }

    print('🎯 Итог: успешно извлечено ${newsItems.length} новостей из карусели');
    return newsItems;
  }

  static List<NewsItem> _fallbackParseNews(document) {
    final newsItems = <NewsItem>[];
    
    // Альтернативный метод: ищем по структуре с датой и заголовком
    final allElements = document.querySelectorAll('*');
    
    for (var element in allElements) {
      try {
        // Ищем элементы, которые содержат структуру похожую на новость
        final dateElement = element.querySelector('p.info');
        final titleElement = element.querySelector('p.title');
        final linkElement = element.querySelector('a[href*="volpt.ru"]');
        
        if (dateElement != null && titleElement != null && linkElement != null) {
          final date = dateElement.text.trim();
          final title = titleElement.text.trim();
          final href = linkElement.attributes['href'];
          final description = element.querySelector('p[style*="color: #555"]')?.text?.trim() ?? '';
          final imageUrl = element.querySelector('img')?.attributes['src'];

          if (date.isNotEmpty && title.isNotEmpty) {
            newsItems.add(NewsItem(
              title: title,
              description: _cleanDescription(description),
              date: date,
              imageUrl: imageUrl != null ? _makeAbsoluteUrl(imageUrl) : null,
              link: href != null ? _makeAbsoluteUrl(href) : null,
            ));
          }
        }
      } catch (e) {
        // Пропускаем ошибки в отдельных элементах
      }
    }
    
    return newsItems;
  }

  static String _cleanDescription(String text) {
    final cleanText = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    if (cleanText.length > 150) {
      return '${cleanText.substring(0, 150)}...';
    }
    
    return cleanText.isNotEmpty ? cleanText : 'Новость Волжского политехнического техникума';
  }

  static String _makeAbsoluteUrl(String url) {
    if (url.startsWith('http')) return url;
    return '$baseUrl${url.startsWith('/') ? url : '/$url'}';
  }
}