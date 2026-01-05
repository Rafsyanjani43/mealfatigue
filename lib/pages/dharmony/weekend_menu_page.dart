import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Tambahkan ini
import 'weekend_menu_detail.dart';

// --- Definisi Warna Tema ---
const Color primaryOrange = Color(0xFFFF6B4A);
const Color darkNavy = Color(0xFF1E293B);
const Color cardSurface = Color(0xFFF6F8FA);
const Color textGrey = Color(0xFF64748B);

class WeekendMenuPage extends StatefulWidget {
  const WeekendMenuPage({Key? key}) : super(key: key);

  @override
  State<WeekendMenuPage> createState() => _WeekendMenuPageState();
}

class _WeekendMenuPageState extends State<WeekendMenuPage> {
  // Fungsi untuk mengambil semua data resep dari Supabase
  Future<List<Map<String, dynamic>>> fetchAllRecipes() async {
    final response = await Supabase.instance.client
        .from('recipes')
        .select();
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(Icons.arrow_back, color: darkNavy, size: 20),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAllRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryOrange));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No menu available in database."));
          }

          final recipes = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Weekend Menu Options",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: darkNavy, height: 1.2),
                ),
                const SizedBox(height: 4),
                const Text("Pick up together", style: TextStyle(fontSize: 14, color: textGrey)),
                const SizedBox(height: 30),

                // --- LOOPING KARTU BERDASARKAN DATA SUPABASE ---
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final item = recipes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WeekendMenuDetailPage(
                                recipe: item, // Mengirim data Map lengkap ke detail
                              ),
                            ),
                          );
                        },
                        child: _buildPremiumCard(
                          title: item['title'] ?? 'No Title',
                          matchPercent: item['match_perce'] ?? '0%', // Pakai nama kolom database Anda
                          description: item['description'] ?? '',
                          tags: ["Win-win", "Healthy"], // Bisa disesuaikan nanti
                          personA: "High Protein",
                          personB: "Plant-based",
                          time: item['time'] ?? '-',
                          price: item['price'] ?? '-',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER: KARTU MENU PREMIUM (Tetap sama seperti kodingan Anda) ---
  Widget _buildPremiumCard({
    required String title,
    required String matchPercent,
    required String description,
    required List<String> tags,
    required String personA,
    required String personB,
    required String time,
    required String price,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: darkNavy.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: darkNavy, height: 1.2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: primaryOrange,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: primaryOrange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                      ),
                      child: Text(
                        "$matchPercent Match",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(description, style: const TextStyle(fontSize: 13, color: textGrey, height: 1.5)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: cardSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: darkNavy)),
                  )).toList(),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [Icon(Icons.person, size: 16, color: darkNavy), SizedBox(width: 6), Text("Person A", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkNavy))]),
                      const SizedBox(height: 4),
                      Text(personA, style: const TextStyle(fontSize: 12, color: textGrey)),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [Icon(Icons.person_outline, size: 16, color: primaryOrange), SizedBox(width: 6), Text("Person B", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryOrange))]),
                      const SizedBox(height: 4),
                      Text(personB, style: const TextStyle(fontSize: 12, color: textGrey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9).withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [const Icon(Icons.access_time_rounded, size: 16, color: textGrey), const SizedBox(width: 6), Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: darkNavy))]),
                Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: primaryOrange)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}