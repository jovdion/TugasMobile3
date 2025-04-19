import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> helpItems = const [
    {
      'title': 'Stopwatch',
      'desc': 'Gunakan tombol play untuk mulai, pause untuk berhenti, reset untuk ulang.'
    },
    {
      'title': 'Deteksi Bilangan',
      'desc': 'Masukkan angka untuk melihat tipenya (prima, desimal, bulat, dll).'
    },
    {
      'title': 'Tracking LBS',
      'desc': 'Izinkan akses lokasi untuk melihat posisi Anda di peta.'
    },
    {
      'title': 'Konversi Waktu',
      'desc': 'Masukkan jumlah tahun untuk dikonversi ke hari, jam, menit, dan detik.'
    },
    {
      'title': 'Rekomendasi Situs',
      'desc': 'Klik list item untuk buka link, tap ikon hati untuk menandai favorit.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan & Logout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Daftar instruksi bantuan
            Expanded(
              child: ListView.builder(
                itemCount: helpItems.length,
                itemBuilder: (context, index) {
                  final item = helpItems[index];
                  return ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(
                      item['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(item['desc']!),
                  );
                },
              ),
            ),
            // Tombol Logout dengan dialog konfirmasi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _confirmLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // tutup dialog
              context.read<AuthProvider>().logout(); // panggil logout
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
