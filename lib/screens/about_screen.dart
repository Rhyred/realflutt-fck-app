import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Untuk ikon tambahan jika perlu

import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class TeamMember {
  final String name;
  final String role;
  final String? imageUrl; // Path ke aset gambar lokal
  final String? githubUrl;
  final String? email;
  final String? instagramUrl;
  final String? linkedinUrl;

  TeamMember({
    required this.name,
    required this.role,
    this.imageUrl,
    this.githubUrl,
    this.email,
    this.instagramUrl,
    this.linkedinUrl,
  });
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  final String appVersion = "Versi 2.1.1"; // Versi diperbarui

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Bisa tambahkan fallback atau error handling di sini
      // Misalnya, menampilkan Snackbar jika URL tidak bisa dibuka
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<TeamMember> teamMembers = [
      TeamMember(
        name: 'Najwa hikmatyar', // Nama dikoreksi
        role: 'Embedded Systems Engineer/IoT Dev',
        // imageUrl: 'assets/team/najwa.png', // Contoh jika ada gambar
        githubUrl: 'https://github.com/Chwyper',
        email: 'najwahikmatyar25@gmail.com',
        instagramUrl:
            'https://www.instagram.com/hary.ary_?igsh=MTVwOW5ta2Q0NDhqYw==',
      ),
      TeamMember(
        name: 'Robi Rizki Permana',
        role: 'IoT Stack Dev and Backend Developer',
        imageUrl:
            'assets/team/Robi_Rizki_Permana.png', // Path gambar diperbarui
        githubUrl: 'https://github.com/Rhyred',
        email: 'robigold9@gmail.com',
        instagramUrl:
            'https://www.instagram.com/rake_rhyred?igsh=MWI5aGszdTRzcmFlYw==',
      ),
      TeamMember(
        name: 'Putri Yudi P', // Nama dikoreksi
        role: 'Prototyper and Documentation',
        // imageUrl: 'assets/team/putri.png', // Contoh
        email: 'putriyudii90@gmail.com',
        instagramUrl:
            'https://www.instagram.com/putriyudii_/profilecard/?igsh=MTAzZ2Q2cnNnMnlkYQ==',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        automaticallyImplyLeading: false, // Karena ini bagian dari BottomNav
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          // Tambahkan logo aplikasi di sini
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Image.asset(
              'assets/app_icon.png', // Path ke logo aplikasi Anda
              height: 80, // Sesuaikan ukuran logo jika perlu
              width: 80,
            ),
          ),
          Text(
            'Smart Parking App',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Aplikasi manajemen parkir pintar berbasis Android', // Sesuai gambar, meskipun ini aplikasi mobile
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 24.0),
          _buildSectionTitle(context, 'Tentang Proyek'),
          const SizedBox(height: 8.0),
          Text(
            'Smart Parking App adalah aplikasi yang memungkinkan pengguna untuk melihat ketersediaan slot parkir secara real-time, melakukan booking, dan melakukan pembayaran secara digital. Aplikasi ini menggunakan teknologi sensor TTP226/ESP32 untuk mendeteksi keberadaan kendaraan di slot parkir dan menyimpan data booking di database.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 24.0),
          _buildSectionTitle(context, 'Tim Pengembang'),
          const SizedBox(height: 12.0),
          ...teamMembers // Hapus .toList()
              .map((member) => _buildTeamMemberTile(context, member)),
          const SizedBox(height: 32.0),
          Text(
            '© ${DateTime.now().year} Smart Parking Team. All rights reserved.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4.0),
          Text(
            appVersion,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20.0), // Extra padding at the bottom
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            // color: Theme.of(context).colorScheme.primary, // Bisa juga primary color
          ),
    );
  }

  Widget _buildTeamMemberTile(BuildContext context, TeamMember member) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Theme.of(context).dividerColor, width: 0.5)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  member.imageUrl != null ? AssetImage(member.imageUrl!) : null,
              child: member.imageUrl == null
                  ? Icon(Icons.person, size: 30, color: Colors.grey[600])
                  : null,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    member.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    member.role,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      if (member.githubUrl != null)
                        _buildSocialIcon(
                            context, // Tambah context
                            FontAwesomeIcons.github,
                            member.githubUrl!),
                      if (member.email != null)
                        _buildSocialIcon(
                            context, // Tambah context
                            Icons.email_outlined,
                            'mailto:${member.email!}'),
                      if (member.instagramUrl != null)
                        _buildSocialIcon(
                            context, // Tambah context
                            FontAwesomeIcons.instagram,
                            member.instagramUrl!),
                      if (member.linkedinUrl != null)
                        _buildSocialIcon(
                            context, // Tambah context
                            FontAwesomeIcons.linkedinIn,
                            member.linkedinUrl!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon, String url) {
    // Tambah context
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: IconButton(
        icon:
            FaIcon(icon, size: 18), // Menggunakan FaIcon jika dari FontAwesome
        color: Theme.of(context)
            .colorScheme
            .primary
            .withAlpha((255 * 0.8).round()), // Menggunakan withAlpha
        tooltip: url.startsWith('mailto:') ? url.substring(7) : url,
        onPressed: () => _launchURL(url),
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// Hapus extension TeamMemberImageUrl karena imageUrl sudah ada di model
// extension TeamMemberImageUrl on TeamMember {
//   String? get imageUrl => null;
// }
