import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  void _login() {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      if (username == 'admin' && password == 'admin') {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage('Username atau password salah');
      }

      setState(() => _isLoading = false);
    });
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 16),
                const Text(
                  "Selamat Datang,",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Log in untuk melanjutkan",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: Icon(Icons.visibility),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showMessage('Fitur lupa password tidak tersedia');
                    },
                    child: const Text("Lupa Password Anda?"),
                  ),
                ),

                const SizedBox(height: 16),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "Masuk",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text("atau belum punya akun? Daftar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
