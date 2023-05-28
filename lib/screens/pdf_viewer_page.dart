import 'package:easy_gaadi/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {
  final SfPdfViewer pdfViewer;
  const PdfViewerPage({super.key, required this.pdfViewer});

  @override
  Widget build(BuildContext context) {
    return Background(
      child: pdfViewer,
    );
  }
}
