import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  final String teamName = 'Smart Parking Team';
  final List<Map<String, String>> creators = const [
    {'name': 'Creator 1', 'role': 'Developer'},
    {'name': 'Creator 2', 'role': 'Designer'},
    {'name': 'Creator 3', 'role': 'Project Manager'},
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
                return ListTile(
                  leading: const Icon(Icons.person, color: Colors.white70),
                  title: Text(
                    creator['name']!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    creator['role']!,
                    style: const TextStyle(color: Colors.white70),
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
