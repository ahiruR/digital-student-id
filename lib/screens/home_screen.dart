import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'scan_screen.dart';
import 'attendance_history_screen.dart';
import 'qr_code_screen.dart';
import 'account_settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('デジタル学生証'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AttendanceHistoryScreen()),
              );
            },
            tooltip: '出席履歴',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
              );
            },
            tooltip: 'アカウント設定',
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('students').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('学生データが見つかりません'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? '';
          final studentId = data['studentId'] ?? '';
          final role = UserRoleExtension.fromString(data['role']);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // ID情報カード(QRなし)
                Container(
                  width: 340,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.brass, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                        child: Row(
                          children: [
                            const Icon(Icons.school_outlined, color: AppColors.brass, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'STUDENT IDENTIFICATION',
                              style: GoogleFonts.notoSansJp(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.brass),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                role.label,
                                style: GoogleFonts.notoSansJp(
                                  color: AppColors.brass,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 1, color: AppColors.brass.withValues(alpha: 0.5)),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 76,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.brass, width: 1),
                              ),
                              child: const Icon(Icons.person_outline, size: 44, color: AppColors.navy),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.notoSerifJp(
                                      color: Colors.white,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    role == UserRole.student ? '学籍番号' : '職員番号',
                                    style: GoogleFonts.notoSansJp(
                                      color: Colors.white.withValues(alpha: 0.55),
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    studentId,
                                    style: GoogleFonts.notoSansJp(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // QRコード表示画面へのボタン
                SizedBox(
                  width: 340,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QrCodeScreen(uid: uid, name: name),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.navy),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.qr_code, color: AppColors.navy),
                    label: Text(
                      '学生証QRコードを表示',
                      style: GoogleFonts.notoSansJp(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // 出席をとるボタン(先生・管理者のみ表示)
                if (role == UserRole.teacher || role == UserRole.admin) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 340,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ScanScreen()),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                      label: const Text('出席をとる'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}