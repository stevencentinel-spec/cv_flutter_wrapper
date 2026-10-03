import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hoja de Vida - Steven Fuentes',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.blueGrey,
      ),
      home: const CvWebViewScreen(),
    );
  }
}

class CvWebViewScreen extends StatefulWidget {
  const CvWebViewScreen({super.key});

  @override
  State<CvWebViewScreen> createState() => _CvWebViewScreenState();
}

class _CvWebViewScreenState extends State<CvWebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF22262F))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => isLoading = false);
            }
          },
        ),
      );

    _loadLocalWebFiles();
  }

  Future<void> _loadLocalWebFiles() async {
    setState(() => isLoading = true);
    final String htmlFile = await rootBundle.loadString('assets/web/index.html');
    final String cssFile = await rootBundle.loadString('assets/web/style.css');

    final String combinedHtml = htmlFile.replaceFirst(
      '<link rel="stylesheet" href="style.css">',
      '<style>$cssFile</style>',
    );

    await controller.loadHtmlString(combinedHtml);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hoja de Vida • UPEC',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF22262F),
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            tooltip: 'Cambiar contraste',
            icon: const Icon(Icons.contrast),
            onPressed: () {
              controller.runJavaScript('toggleThemeFromFlutter();');
            },
          ),
          IconButton(
            tooltip: 'Recargar CV',
            icon: const Icon(Icons.refresh),
            onPressed: _loadLocalWebFiles,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFC59B27),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC59B27),
        tooltip: 'Subir al inicio',
        onPressed: () {
          controller.runJavaScript(
            'window.scrollTo({top: 0, behavior: "smooth"});',
          );
        },
        child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
      ),
    );
  }
}