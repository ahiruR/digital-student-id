import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isProcessing = false;

  Future<void> _handleScan(String studentUid) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentUid)
          .get();

      if (!studentDoc.exists) {
        _showResultDialog('読み取りエラー', '該当する学生証が見つかりませんでした', isError: true);
        return;
      }

      final studentData = studentDoc.data()!;
      final studentName = studentData['name'] ?? '不明';

      await FirebaseFirestore.instance.collection('attendances').add({
        'studentUid': studentUid,
        'studentName': studentName,
        'scannedBy': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showResultDialog('出席を記録しました', '$studentName さん');
    } catch (e) {
      _showResultDialog('読み取りエラー', '処理中に問題が発生しました', isError: true);
    }
  }

  void _showResultDialog(String title, String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        icon: Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: isError ? AppColors.error : AppColors.success,
          size: 36,
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSerifJp(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: AppColors.navy,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansJp(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _isProcessing = false);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.navy),
              child: const Text('閉じる'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('QRコードで出席をとる'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  _handleScan(code);
                }
              }
            },
          ),

          // スキャン枠のオーバーレイ(中央に真鍮色のコーナーマーク)
          IgnorePointer(
            child: Center(
              child: SizedBox(
                width: 240,
                height: 240,
                child: CustomPaint(
                  painter: _ScanFramePainter(),
                ),
              ),
            ),
          ),

          // 下部の案内テキスト
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  '学生証のQRコードを枠内に合わせてください',
                  style: GoogleFonts.notoSansJp(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_isProcessing) ...[
                  const SizedBox(height: 12),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.brass,
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// スキャン枠の四隅だけを描く真鍮色のコーナーマーク
class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brass
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerLength = 28.0;

    // 左上
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // 右上
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // 左下
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // 右下
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}