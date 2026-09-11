import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('アカウント設定')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('students').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('データが見つかりません'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final role = UserRoleExtension.fromString(data['role']);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _InfoTile(label: '氏名', value: data['name'] ?? ''),
              _InfoTile(
                label: role == UserRole.student ? '学籍番号' : '職員番号',
                value: data['studentId'] ?? '',
              ),
              _InfoTile(label: 'メールアドレス', value: data['email'] ?? ''),
              _InfoTile(label: '役割', value: role.label),
              const SizedBox(height: 24),

              // パスワード再設定
              _ActionTile(
                icon: Icons.lock_outline,
                label: 'パスワードを再設定する',
                onTap: () async {
                  final error = await authService.sendPasswordResetEmail(data['email'] ?? '');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error ?? '再設定メールを送信しました'),
                        backgroundColor: error != null ? AppColors.error : AppColors.success,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),

              // ログアウト
              _ActionTile(
                icon: Icons.logout,
                label: 'ログアウト',
                color: AppColors.error,
                onTap: () => authService.signOut(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSansJp(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.notoSansJp(fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFFE0DED8)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.navy),
        title: Text(
          label,
          style: GoogleFonts.notoSansJp(color: color ?? AppColors.textPrimary),
        ),
        onTap: onTap,
      ),
    );
  }
}