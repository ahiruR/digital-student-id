import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class QrCodeScreen extends StatelessWidget {
  final String uid;
  final String name;

  const QrCodeScreen({super.key, required this.uid, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('学生証QRコード'),
        backgroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.brass, width: 1),
              ),
              child: QrImageView(
                data: uid,
                version: QrVersions.auto,
                size: 220,
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              name,
              style: GoogleFonts.notoSerifJp(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '端末にかざして出席を記録します',
              style: GoogleFonts.notoSansJp(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}