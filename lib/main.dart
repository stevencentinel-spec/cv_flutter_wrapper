import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import 'webview_web_stub.dart'
if (dart.library.html) 'webview_web_impl.dart';

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
  WebViewController? controller;
  bool isLoading = true;
  bool isDarkTheme = false;
  String viewId = 'cv-webview-0';
  int reloadCounter = 0;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF1C2128))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => isLoading = false);
            },
          ),
        );
    }
    _loadLocalWebFiles();
  }

  Future<void> _loadLocalWebFiles({bool toggleTheme = false}) async {
    setState(() => isLoading = true);
    if (toggleTheme) {
      isDarkTheme = !isDarkTheme;
    }

    String htmlFile = await rootBundle.loadString('assets/web/index.html');
    final String cssFile = await rootBundle.loadString('assets/web/style.css');

    htmlFile = htmlFile.replaceFirst(
      '<link rel="stylesheet" href="style.css">',
      '<style>$cssFile</style>',
    );

    if (isDarkTheme) {
      htmlFile = htmlFile.replaceFirst('<body>', '<body class="alt-theme">');
    }

    if (kIsWeb) {
      reloadCounter++;
      viewId = 'cv-webview-$reloadCounter';
      registerWebIframe(htmlFile, viewId);
      if (mounted) setState(() => isLoading = false);
    } else {
      await controller?.loadHtmlString(htmlFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hoja de Vida • UPEC',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1C2128),
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            tooltip: 'Cambiar contraste (Modo Claro/Oscuro)',
            icon: const Icon(Icons.contrast),
            onPressed: () {
              if (kIsWeb) {
                _loadLocalWebFiles(toggleTheme: true);
              } else {
                controller?.runJavaScript('toggleThemeFromFlutter();');
              }
            },
          ),
          IconButton(
            tooltip: 'Recargar CV',
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadLocalWebFiles(toggleTheme: false),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (kIsWeb)
            buildWebIframe(viewId)
          else if (controller != null)
            WebViewWidget(controller: controller!),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFB89146),
              ),
            ),
        ],
      ),
    );
  }
}