import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'NewsDetails.dart';

const apiKey = "c87d4593318b440fa30c2084262a35ef";
const apiUrl =
    "https://newsapi.org/v2/top-headlines?country=us&category=health&apiKey=$apiKey";

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late final Future<List<dynamic>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = fetchNews();
  }

  Future<List<dynamic>> fetchNews() async {
    final resp = await http.get(Uri.parse(apiUrl));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load news');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['articles'] as List<dynamic>;
  }

  String limitText(String text, [int max = 100]) {
    if (text.length <= max) return text;
    return text.substring(0, max) + '…';
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Articles')),
      body: FutureBuilder<List<dynamic>>(
        future: _articlesFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final articles = snap.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: articles.length,
            itemBuilder: (ctx, i) {
              final article = articles[i] as Map<String, dynamic>;
              final title = article['title'] as String? ?? 'No Title';
              final description = article['description'] as String? ?? '';
              final imageUrl = article['urlToImage'] as String?;
              final dateRaw = article['publishedAt'] as String? ?? '';
              final publishedAt = dateRaw.split('T').first;
              final author = article['author'] as String? ?? 'Unknown';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    // PENTING: kirim seluruh map 'article' ke detail page
                    Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailPage(article: article),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                          ),
                          child:
                              imageUrl != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (ctx, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder: (ctx, error, stack) {
                                        // misalnya CORS atau 404
                                        return const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  )
                                  : const Icon(
                                    Icons.article,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                        ),

                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                limitText(description),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'By $author • $publishedAt',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
