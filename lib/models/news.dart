//lib/models/news.dart
class NewsItem {
  final String title;
  final String description;
  final String date;
  final String? imageUrl;
  final String? link;

  NewsItem({
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl,
    this.link,
  });
}