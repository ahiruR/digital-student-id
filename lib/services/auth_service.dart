import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, teacher, admin }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String? value) {
    switch (value) {
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }

  String get label {
    switch (this) {
      case UserRole.student:
        return '生徒';
      case UserRole.teacher:
        return '先生';
      case UserRole.admin:
        return '管理者';
    }
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signUp({
    required String email,
    required String password,
    required String studentId,
    required String name,
    required UserRole role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = result.user!.uid;

      await _firestore.collection('students').doc(uid).set({
        'uid': uid,
        'studentId': studentId,
        'name': name,
        'email': email,
        'role': role.value,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // パスワード再設定メールを送信
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // 現在ログイン中ユーザーのロールを取得
  Future<UserRole> getCurrentUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return UserRole.student;

    final doc = await _firestore.collection('students').doc(uid).get();
    if (!doc.exists) return UserRole.student;

    return UserRoleExtension.fromString(doc.data()?['role']);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}