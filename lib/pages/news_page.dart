import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List articles = [];
  bool isLoading = false;
  bool showScrollToTop = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchNews();

    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !showScrollToTop) {
        setState(() => showScrollToTop = true);
      } else if (_scrollController.offset <= 300 && showScrollToTop) {
        setState(() => showScrollToTop = false);
      }
    });
  }

  Future<void> fetchNews() async {
    setState(() => isLoading = true);
    const apiKey = '18bc83d8a4f7f0ff986fd99eef0bc02b'; 
    final url = Uri.parse(
        'https://gnews.io/api/v4/top-headlines?lang=id&country=id&max=15&token=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          articles = data['articles'];
        });
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Gagal memuat berita: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📰 Berita Hari Ini"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: fetchNews,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showDetail(article),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                              child: CachedNetworkImage(
                                imageUrl: article['image'] ?? '',
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(height: 180, color: Colors.grey[300]),
                                errorWidget: (context, url, error) => Container(
                                  height: 180,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported, size: 50),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article['title'] ?? 'Tanpa Judul',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    article['description'] ?? 'Tidak ada deskripsi',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Sumber: ${article['source']['name']}",
                                    style: TextStyle(color: Colors.indigo[600], fontSize: 12),
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
              ),
      ),
      floatingActionButton: showScrollToTop
          ? FloatingActionButton(
              backgroundColor: Colors.indigo,
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
    );
  }

  void _showDetail(dynamic article) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article['title'] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(article['description'] ?? 'Tidak ada deskripsi'),
                const SizedBox(height: 12),
                if (article['url'] != null)
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.link),
                    label: Text(article['url']),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
