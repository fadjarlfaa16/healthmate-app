import 'package:flutter/material.dart';

class NewsDetailPage extends StatelessWidget {
  final Map<String, dynamic> article;

  const NewsDetailPage({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = article['title'] ?? 'No Title';
    final content =
        article['content'] ?? article['description'] ?? 'No Content Available';
    final imageUrl = article['urlToImage'];
    final source = article['source']?['name'] ?? 'Unknown Source';
    final publishedAt = article['publishedAt'] ?? '';
    final url = article['url'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  source,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl),
              ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              "Published: ${publishedAt.split("T").first}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (url != null)
              TextButton.icon(
                icon: const Icon(Icons.link),
                label: const Text("Read Full Article"),
                onPressed: () {
                  // bisa ditambahkan url_launcher
                },
              ),
          ],
        ),
      ),
    );
  }
}
