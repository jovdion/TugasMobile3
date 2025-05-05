import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          'Bantuan & FAQ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFAQSection(
            context, 
            'Umum', 
            [
              FAQItem(
                'Bagaimana cara menggunakan aplikasi ini?',
                'Aplikasi ini memiliki berbagai fitur yang dapat diakses melalui menu Beranda. Pilih fitur yang ingin digunakan dengan mengetuk kartu menu yang sesuai.'
              ),
              FAQItem(
                'Apakah aplikasi ini gratis?',
                'Ya, aplikasi ini sepenuhnya gratis dan dikembangkan sebagai proyek tugas kuliah.'
              ),
            ]
          ),
          _buildFAQSection(
            context,
            'Fitur Aplikasi',
            [
              FAQItem(
                'Stopwatch',
                'Fitur ini berfungsi sebagai penghitung waktu. Gunakan tombol play untuk memulai, pause untuk menghentikan sementara, dan reset untuk mengulang dari awal. Anda juga dapat mencatat waktu lap dengan menekan tombol lap saat stopwatch berjalan.'
              ),
              FAQItem(
                'Deteksi Bilangan',
                'Fitur ini membantu Anda menentukan jenis bilangan. Masukkan angka pada form input untuk melihat apakah bilangan tersebut prima, genap, ganjil, desimal, atau bulat. Sistem akan menampilkan hasil analisis secara otomatis.'
              ),
              FAQItem(
                'Tracking LBS',
                'Fitur ini menampilkan lokasi Anda di peta. Izinkan akses lokasi saat diminta oleh aplikasi. Anda dapat melihat posisi real-time dan melakukan refresh lokasi dengan menekan tombol refresh.'
              ),
              FAQItem(
                'Konversi Waktu',
                'Fitur ini mengonversi satuan waktu. Masukkan jumlah dalam satu satuan waktu (misalnya tahun) dan sistem akan menghitung konversinya ke satuan waktu lain seperti bulan, hari, jam, menit, dan detik secara otomatis.'
              ),
              FAQItem(
                'Rekomendasi Situs',
                'Fitur ini menyediakan daftar situs web yang direkomendasikan. Ketuk pada item untuk membuka link, dan tekan ikon hati untuk menandai sebagai favorit. Situs yang ditandai favorit akan muncul di bagian atas daftar.'
              ),
            ]
          ),
          _buildFAQSection(
            context,
            'Masalah Umum',
            [
              FAQItem(
                'Aplikasi berjalan lambat',
                'Cobalah untuk menutup aplikasi lain yang berjalan di latar belakang dan pastikan memori perangkat Anda mencukupi. Jika masalah berlanjut, coba restart perangkat Anda.'
              ),
              FAQItem(
                'Fitur tracking tidak menemukan lokasi saya',
                'Pastikan layanan lokasi perangkat Anda diaktifkan dan aplikasi memiliki izin akses lokasi. Periksa juga koneksi internet Anda karena fitur ini memerlukan koneksi internet yang stabil.'
              ),
            ]
          ),
          _buildFAQSection(
            context,
            'Privasi & Keamanan',
            [
              FAQItem(
                'Izin apa yang dibutuhkan aplikasi?',
                'Aplikasi ini membutuhkan izin akses lokasi untuk fitur tracking, akses internet untuk fitur rekomendasi situs, dan izin penyimpanan untuk menyimpan data lokal.'
              ),
            ]
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _confirmLogout(context),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context, String title, List<FAQItem> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          ...items.map((item) => _buildFAQItem(context, item)).toList(),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, FAQItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            item.question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 12,
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: Icon(
            Icons.help_outline,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          children: [
            Text(
              item.answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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

class FAQItem {
  final String question;
  final String answer;

  FAQItem(this.question, this.answer);
}
