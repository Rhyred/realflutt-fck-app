import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        backgroundColor: Colors.black, // Sesuaikan dengan tema
        automaticallyImplyLeading:
            false, // Sembunyikan tombol kembali jika ini adalah tab utama
      ),
      backgroundColor: Colors.black, // Sesuaikan dengan tema
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Smart Parking App',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Versi 1.0.0', // Contoh versi
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Dibuat untuk mempermudah pencarian dan pemesanan tempat parkir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white70,
                ),
              ),
              // Anda bisa menambahkan informasi lain di sini
            ],
          ),
        ),
      ),
    );
  }
}
