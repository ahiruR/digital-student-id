import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _authService = AuthService();

  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await _authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      studentId: _studentIdController.text.trim(),
      name: _nameController.text.trim(),
      role: _selectedRole,
    );

    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });

    if (error == null && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('新規登録')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              '学生情報の登録',
              style: GoogleFonts.notoSerifJp(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '正確な情報を入力してください',
              style: GoogleFonts.notoSansJp(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),

            // ロール選択(デモ用:本来は運用側で管理します)
            Text(
              '役割',
              style: GoogleFonts.notoSansJp(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD8D5CE)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: UserRole.values.map((role) {
                  final isSelected = _selectedRole == role;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedRole = role),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: isSelected ? AppColors.navy : Colors.transparent,
                        child: Text(
                          role.label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSansJp(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '氏名'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _studentIdController,
              decoration: InputDecoration(
                labelText: _selectedRole == UserRole.student ? '学籍番号' : '職員番号',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'パスワード(6文字以上)'),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.notoSansJp(color: AppColors.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleSignup,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('登録する'),
            ),
          ],
        ),
      ),
    );
  }
}