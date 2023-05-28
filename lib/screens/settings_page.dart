import 'package:easy_gaadi/screens/pdf_viewer_page.dart';
import 'package:easy_gaadi/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PdfViewerPage(
                              pdfViewer:
                                  SfPdfViewer.asset('assets/docs/T&C.pdf'),
                            )));
              },
              leading: Icon(
                Icons.picture_as_pdf,
                size: 30.sp,
                color: Colors.black,
              ),
              title: Text(
                'Terms & conditions',
                style: GoogleFonts.montserrat(
                  fontSize: 18.sp,
                  color: Colors.black,
                ),
                textScaleFactor: 1.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
