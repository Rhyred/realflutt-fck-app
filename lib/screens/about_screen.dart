import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dan backgroundColor akan mengambil dari tema
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        // Padding tetap, const bisa dihilangkan jika child tidak const
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Smart Parking App',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .primary, // Warna primary untuk judul
                    ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Versi 1.0.0', // Contoh versi
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge, // Menggunakan style dari tema
              ),
              const SizedBox(height: 8.0),
              Text(
                'Dibuat untuk mempermudah pencarian dan pemesanan tempat parkir.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium, // Menggunakan style dari tema
              ),
              // Anda bisa menambahkan informasi lain di sini
            ],
          ),
        ),
      ),
    );
  }
}
