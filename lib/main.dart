import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/news_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Berita Hari Ini',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const NewsPage(),
    );
  }
}
