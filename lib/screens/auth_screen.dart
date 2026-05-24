import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rep_max/services/firebase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _firebaseService = FirebaseService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await _firebaseService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await _firebaseService.signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _displayNameController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Authentication error';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'ログイン' : 'ユーザー登録'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // タイトル
            Text(
              '筋トレ記録\nRep Max',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48.0),

            // エラーメッセージ
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            if (_errorMessage != null) const SizedBox(height: 16.0),

            // 表示名フィールド（登録時のみ）
            if (!_isLogin)
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  hintText: '表示名',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                enabled: !_isLoading,
              ),
            if (!_isLogin) const SizedBox(height: 16.0),

            // メールアドレスフィールド
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'メールアドレス',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16.0),

            // パスワードフィールド
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'パスワード',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 32.0),

            // 認証ボタン
            ElevatedButton(
              onPressed: _isLoading ? null : _authenticate,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  _isLogin ? 'ログイン' : 'ユーザー登録',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // 切り替えボタン
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _errorMessage = null;
                        _displayNameController.clear();
                        _emailController.clear();
                        _passwordController.clear();
                      });
                    },
              child: Text(
                _isLogin
                    ? 'ユーザー登録はこちら'
                    : 'ログインはこちら',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
