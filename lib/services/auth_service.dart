import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 現在ログイン中のユーザーの状態を監視する
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 新規登録:メールアドレス・パスワード・学籍番号・氏名を受け取る
  Future<String?> signUp({
    required String email,
    required String password,
    required String studentId,
    required String name,
  }) async {
    try {
      // Firebase Authenticationにユーザーを作成
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = result.user!.uid;

      // Firestoreの「students」コレクションに学生情報を保存
      await _firestore.collection('students').doc(uid).set({
        'uid': uid,
        'studentId': studentId,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // 成功時はnullを返す
    } on FirebaseAuthException catch (e) {
      return e.message; // エラーメッセージを返す
    }
  }

  // ログイン
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ログアウト
  Future<void> signOut() async {
    await _auth.signOut();
  }
}