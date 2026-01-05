import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({Key? key}) : super(key: key);

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _newEmailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePass = true;

  static const primaryOrange = Color(0xFFFF6B4A);
  static const textColor = Color(0xFF333333);

  Future<void> _handleChangeEmail() async {
    String newEmail = _newEmailCtrl.text.trim();
    String password = _passwordCtrl.text.trim();

    if (newEmail.isEmpty || password.isEmpty) {
      _showSnackbar("Silakan isi semua kolom", Colors.red);
      return;
    }

    if (!newEmail.toLowerCase().endsWith("@gmail.com")) {
      _showSnackbar("Email harus menggunakan @gmail.com", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;

      // 1. Validasi ulang password (Re-authentication)
      await Supabase.instance.client.auth.signInWithPassword(
        email: user!.email!,
        password: password,
      );

      // 2. Cek apakah email baru sama dengan email lama
      if (newEmail == user.email) {
        throw 'Email baru tidak boleh sama dengan email lama';
      }

      // 3. Update Email
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(email: newEmail),
      );

      if (!mounted) return;
      _showSnackbar("Email berhasil diperbarui!", Colors.green);

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);

    } on AuthException catch (error) {
      if (mounted) _showSnackbar(error.message, Colors.red);
    } catch (error) {
      if (mounted) _showSnackbar(error.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Change Email",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Masukkan email baru dan password akun Anda saat ini untuk mengonfirmasi perubahan.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 40),

            // Field Email Baru
            TextField(
              controller: _newEmailCtrl,
              decoration: inputDecoration.copyWith(hintText: 'Email Baru'),
            ),
            const SizedBox(height: 16),

            // Field Password
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscurePass,
              decoration: inputDecoration.copyWith(
                hintText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Tombol Update
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleChangeEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                  "Update Email",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}