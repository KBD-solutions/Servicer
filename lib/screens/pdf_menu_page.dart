import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfMenuPage extends StatefulWidget {
  const PdfMenuPage({super.key});

  @override
  State<PdfMenuPage> createState() => _PdfMenuPageState();
}

class _PdfMenuPageState extends State<PdfMenuPage> {
  late final PdfControllerPinch _controller;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(
      document: PdfDocument.openAsset('assets/Menu.pdf'),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: PdfViewPinch(controller: _controller),
    );
  }
}