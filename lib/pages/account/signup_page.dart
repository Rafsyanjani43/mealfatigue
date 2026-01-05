import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/logo_widget.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controller asli Anda
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Warna utama tema oranye
  static const primaryOrange = Color(0xFFFF6B4A);

  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    // 1. Validasi Input Kosong
    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showSnackbar('Please fill all fields', Colors.black);
      return;
    }

    // 2. Validasi Email khusus @gmail.com
    if (!email.toLowerCase().endsWith('@gmail.com')) {
      _showSnackbar('Registration is restricted to @gmail.com only', Colors.red);
      return;
    }

    // 3. Validasi Panjang Password (Min 8 Karakter)
    if (pass.length < 8) {
      _showSnackbar('Password must be at least 8 characters long', Colors.red);
      return;
    }

    // 4. Validasi Konfirmasi Password (Harus Match)
    if (pass != confirm) {
      _showSnackbar('Passwords do not match', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Logika Database Supabase Asli Anda
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: pass,
      );

      if (mounted) {
        _showSnackbar('Cek email Anda untuk konfirmasi pendaftaran!', Colors.green);
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    } on AuthException catch (error) {
      if (mounted) _showSnackbar(error.message, Colors.red);
    } catch (error) {
      if (mounted) _showSnackbar('Gagal melakukan pendaftaran', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper untuk Snackbar
  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF333333);

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios, size: 18, color: textColor),
                    SizedBox(width: 8),
                    Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: Transform.scale(
                  scale: 2.5,
                  child: const LogoWidget(big: false),
                ),
              ),
              const SizedBox(height: 50),
              const Center(
                child: Text(
                  "Buat Akun Baru",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              const SizedBox(height: 35),

              // Form Input Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: inputDecoration.copyWith(hintText: 'Email (@gmail.com)'),
              ),
              const SizedBox(height: 12),

              // Form Input Password
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: inputDecoration.copyWith(
                  hintText: 'Password (Min 8 characters)',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey, size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Form Input Confirm Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: inputDecoration.copyWith(
                  hintText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off, color: Colors.grey, size: 20),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 35),

              // Tombol Sign Up
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                      children: [
                        const TextSpan(text: "Already have an account? "),
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(color: primaryOrange.withOpacity(0.8), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}