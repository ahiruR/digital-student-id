import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isProcessing = false; // 連続スキャンを防ぐためのフラグ

  Future<void> _handleScan(String studentUid) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // スキャンしたUIDが実在する学生か確認
      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentUid)
          .get();

      if (!studentDoc.exists) {
        _showResultDialog('エラー', '該当する学生が見つかりません', isError: true);
        return;
      }

      final studentData = studentDoc.data()!;
      final studentName = studentData['name'] ?? '不明';

      // 出席記録をFirestoreの「attendances」コレクションに保存
      await FirebaseFirestore.instance.collection('attendances').add({
        'studentUid': studentUid,
        'studentName': studentName,
        'scannedBy': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showResultDialog('出席記録完了', '$studentName さんの出席を記録しました');
    } catch (e) {
      _showResultDialog('エラー', '処理中にエラーが発生しました: $e', isError: true);
    }
  }

  void _showResultDialog(String title, String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(color: isError ? Colors.red : Colors.green),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ダイアログを閉じる
              setState(() => _isProcessing = false); // 再スキャン可能にする
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRコードで出席をとる'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
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
    );
  }
}