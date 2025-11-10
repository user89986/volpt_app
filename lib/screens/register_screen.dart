//lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _groupController = TextEditingController();
  final _supabase = Supabase.instance.client;

  bool _loading = false;
  String? _errorMessage;

  Future<void> _signUp() async {
    setState(() => _loading = true);
    try {
      final res = await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = res.user;
      if (user != null) {
        await _supabase.from('profiles').insert({
          'id': user.id,
          'email': _emailController.text.trim(),
          'group': _groupController.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Регистрация успешна!')),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(controller: _groupController, decoration: const InputDecoration(labelText: 'Группа')),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _signUp,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Зарегистрироваться'),
            ),
          ],
        ),
      ),
    );
  }
}