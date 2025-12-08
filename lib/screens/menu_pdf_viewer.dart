import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:pdfx/pdfx.dart'; 
import 'package:http/http.dart' as http; 

class MenuPdfViewerPage extends StatelessWidget {
  final String menuUrl;

  const MenuPdfViewerPage({super.key, required this.menuUrl});

  // Helper method to fetch PDF bytes
  Future<Uint8List> _fetchPdfData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load PDF from network. Status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Controller is initialized using the fetched byte data.
    final pdfController = PdfController(
      document: PdfDocument.openData(_fetchPdfData(menuUrl)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Menu'),
      ),
      body: PdfView(
        controller: pdfController,

        builders: PdfViewBuilders<dynamic>(
          options: const {},

          builder: (
            BuildContext context,
            PdfViewBuilders builders, 
            PdfLoadingState loadingState, 
            Widget Function(BuildContext) buildDefault, 
            PdfDocument? document, 
            Exception? error, 
          ) {
            
            // 1. Handle error state
            if (loadingState == PdfLoadingState.error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error loading PDF. Viewer failed to render. Error: ${error ?? "Unknown"}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            
            // 2. Handle loading state
            if (loadingState == PdfLoadingState.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 3. Handle success state (render the default page view)
            return buildDefault(context);
          },
        ),
      ),
    );
  }
}