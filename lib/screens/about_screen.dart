import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  final String teamName = 'Smart Parking Team';
  final List<Map<String, dynamic>> creators = const [
    {
      'name': 'Creator 1',
      'role': 'Developer',
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      'instagram': 'https://www.instagram.com/creator1',
      'github': 'https://github.com/creator1',
      'linkedin': 'https://www.linkedin.com/in/creator1',
    },
    {
      'name': 'Creator 2',
      'role': 'Designer',
      'description': 'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      'instagram': 'https://www.instagram.com/creator2',
      'github': 'https://github.com/creator2',
      'linkedin': 'https://www.linkedin.com/in/creator2',
    },
    {
      'name': 'Creator 3',
      'role': 'Project Manager',
      'description': 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
      'instagram': 'https://www.instagram.com/creator3',
      'github': 'https://github.com/creator3',
      'linkedin': 'https://www.linkedin.com/in/creator3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Team: $teamName',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Creators:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16.0),
            ListView.builder(
              shrinkWrap: true,
              itemCount: creators.length,
              itemBuilder: (context, index) {
                final creator = creators[index];
                return Card(
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          creator['name']!,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          creator['role']!,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          creator['description']!,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(FontAwesomeIcons.instagram, color: Colors.white70),
                              onPressed: () async {
                                final url = creator['instagram'] as String?;
                                if (url != null && await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url));
                                } else {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tidak dapat membuka Instagram.')),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(FontAwesomeIcons.github, color: Colors.white70),
                              onPressed: () async {
                                final url = creator['github'] as String?;
                                if (url != null && await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url));
                                } else {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tidak dapat membuka GitHub.')),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(FontAwesomeIcons.linkedin, color: Colors.white70),
                              onPressed: () async {
                                final url = creator['linkedin'] as String?;
                                if (url != null && await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url));
                                } else {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tidak dapat membuka LinkedIn.')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
