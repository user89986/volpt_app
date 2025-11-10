import 'package:flutter/material.dart';
import '../services/news_parser.dart';
import '../models/news.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key, this.embedded = false});

  /// Если embedded=true — отдаём ТОЛЬКО контент без собственного Scaffold/AppBar/FAB,
  /// чтобы NewsScreen красиво встраивался во вкладку HomeScreen.
  final bool embedded;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<NewsItem> _news = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      final news = await NewsParser.fetchNews();
      setState(() {
        _news = news;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Ошибка: $_error'));
    if (_news.isEmpty) return const Center(child: Text('Новости не найдены'));

    return RefreshIndicator(
      onRefresh: _loadNews,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _news.length,
        itemBuilder: (context, index) {
          final news = _news[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(news.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    news.date,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(news.description),
                  if (news.imageUrl != null) ...[
                    const SizedBox(height: 8),
                    Image.network(news.imageUrl!),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      // встроенная версия без собственного Scaffold/FAB/AppBar
      return _buildBody();
    }

    // самостоятельный экран (если вдруг откроешь отдельно)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новости ВПТ'),
        backgroundColor: Colors.blue[800],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadNews,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
