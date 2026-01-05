import 'package:flutter/material.dart';
import 'dart:async';

// --- Definisi Warna Tema ---
const Color primaryOrange = Color(0xFFFF6B4A);
const Color darkNavy = Color(0xFF1E293B);
const Color cardSurface = Color(0xFFF6F8FA);
const Color textGrey = Color(0xFF64748B);

class WeekendCookingModePage extends StatefulWidget {
  final String recipeTitle;
  // Menambahkan parameter untuk menerima langkah dari database
  final List<dynamic>? recipeSteps;

  const WeekendCookingModePage({
    Key? key,
    required this.recipeTitle,
    this.recipeSteps, // Ditambahkan di constructor
  }) : super(key: key);

  @override
  State<WeekendCookingModePage> createState() => _WeekendCookingModePageState();
}

class _WeekendCookingModePageState extends State<WeekendCookingModePage> {
  // Variabel steps sekarang dinamis
  late List<Map<String, dynamic>> _steps;

  int _currentStepIndex = 0;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _initSteps(); // Inisialisasi data dari database
    _remainingSeconds = _steps[0]['duration'] ?? 0;
  }

  // Logika untuk mencocokkan langkah dengan data Supabase
  void _initSteps() {
    if (widget.recipeSteps != null && widget.recipeSteps!.isNotEmpty) {
      _steps = List<Map<String, dynamic>>.from(widget.recipeSteps!);
    } else {
      // Fallback jika data di database kosong agar tidak error
      _steps = [
        {
          "title": "Persiapan",
          "description": "Siapkan bahan-bahan untuk ${widget.recipeTitle}.",
          "duration": 60,
        },
        {
          "title": "Memasak",
          "description": "Masak sesuai instruksi umum untuk hidangan ini.",
          "duration": 300,
        },
        {
          "title": "Selesai",
          "description": "Hidangan siap disajikan!",
          "duration": 0,
        },
      ];
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- LOGIKA TIMER ---
  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() => _isTimerRunning = false);
    } else {
      if (_remainingSeconds <= 0) return;
      setState(() => _isTimerRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          setState(() => _isTimerRunning = false);
          _showTimeUpDialog(); // Notifikasi visual saat waktu habis
        }
      });
    }
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Waktu Habis!"),
        content: const Text("Langkah ini selesai. Siap ke langkah berikutnya?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int min = totalSeconds ~/ 60;
    int sec = totalSeconds % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  // --- LOGIKA NAVIGASI ---
  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _timer?.cancel();
        _isTimerRunning = false;
        _remainingSeconds = _steps[_currentStepIndex]['duration'] ?? 0;
      });
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              content: Text("Masak Selesai! Selamat Menikmati.")
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStepData = _steps[_currentStepIndex];
    double progress = (_currentStepIndex + 1) / _steps.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: darkNavy),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            const Text("COOKING MODE", style: TextStyle(color: textGrey, fontSize: 10, letterSpacing: 1.2)),
            Text(
              widget.recipeTitle,
              style: const TextStyle(color: darkNavy, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Indikator Progres
            LinearProgressIndicator(
              value: progress,
              backgroundColor: cardSurface,
              color: primaryOrange,
              minHeight: 6,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Indikator
                    Text(
                      "STEP ${_currentStepIndex + 1} OF ${_steps.length}".toUpperCase(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: primaryOrange, letterSpacing: 1),
                    ),
                    const SizedBox(height: 12),

                    // Judul & Deskripsi dari DB
                    Text(
                      currentStepData['title'] ?? 'No Title',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: darkNavy, height: 1.1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentStepData['description'] ?? 'No description provided.',
                      style: const TextStyle(fontSize: 17, color: textGrey, height: 1.6),
                    ),

                    const Spacer(),

                    // Timer Section Digital
                    if ((currentStepData['duration'] ?? 0) > 0)
                      Center(
                        child: Column(
                          children: [
                            Text(
                              _formatTime(_remainingSeconds),
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.w200,
                                color: _isTimerRunning ? primaryOrange : darkNavy,
                                fontFamily: 'monospace', // Mengurangi goyangan angka
                              ),
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: _toggleTimer,
                              child: Container(
                                width: 80, height: 80,
                                decoration: BoxDecoration(
                                    color: _isTimerRunning ? Colors.white : darkNavy,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: darkNavy, width: 2),
                                    boxShadow: [BoxShadow(color: darkNavy.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))]
                                ),
                                child: Icon(
                                    _isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: _isTimerRunning ? darkNavy : Colors.white,
                                    size: 40
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                            _currentStepIndex == _steps.length - 1 ? "SELESAI" : "LANGKAH BERIKUTNYA",
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}