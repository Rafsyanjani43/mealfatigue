import 'package:flutter/material.dart';
import '../widgets/logo_widget.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/auth_choice');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Menggunakan Transform.scale untuk memperbesar LogoWidget
              // scale: 1.5 artinya diperbesar 1.5x dari ukuran aslinya
              Transform.scale(
                scale: 2.5,
                child: const LogoWidget(big: true),
              ),

              // Memberi jarak agak jauh antara logo yang besar dengan loading
              const SizedBox(height: 60),

              // Text "Meal Fatigue" telah dihapus

              const CircularProgressIndicator(color: Color(0xFFE7603E)),
            ],
          ),
        ),
      ),
    );
  }
}