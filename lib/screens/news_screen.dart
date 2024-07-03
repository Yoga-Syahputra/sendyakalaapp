import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/news_service.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  void initState() {
    super.initState();
    final newsService = Provider.of<NewsService>(context, listen: false);
    newsService.fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    final newsService = Provider.of<NewsService>(context);

    return Scaffold(
      body: newsService.articles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: newsService.articles.length,
              itemBuilder: (context, index) {
                final article = newsService.articles[index];
                final title = article['title'] ?? 'No title available';
                final imageUrl = article['urlToImage'] ?? 'https://via.placeholder.com/150';
                final author = article['author'] ?? 'Unknown Author';
                final source = article['source']['name'] ?? 'Unknown Source';
                final publishedAt = article['publishedAt'] != null
                    ? DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(article['publishedAt']))
                    : 'Unknown Date';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                        child: imageUrl != null
                            ? Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover)
                            : Container(height: 200, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'By $author',
                              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Source: $source',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Published at: $publishedAt',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (article['url'] != null) {
                                    _launchURL(article['url']);
                                  } else {
                                    print('No URL available for this article');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF003B73),
                                ),
                                child: Text('Read more'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }
}
