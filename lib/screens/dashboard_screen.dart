import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final DatabaseReference _parkingSlotsRef =
      FirebaseDatabase.instance.ref('parking_slots');

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userType = user == null ? 'Guest' : 'Registered';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Parking Dashboard'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder(
        stream: _parkingSlotsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) {
            return const Center(child: Text('Tidak ada data parkir tersedia.'));
          }

          // Asumsi parking_slots di Firebase adalah map seperti { 'slot1': true, 'slot2': false, ... }
          // di mana true berarti terisi/dipesan dan false berarti tersedia.
          final parkingSlots = data.entries.toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: parkingSlots.length,
              itemBuilder: (context, index) {
                final slotEntry = parkingSlots[index];
                final slotNumber = slotEntry.key as String;
                final isOccupied = slotEntry.value as bool;

                return _buildParkingSlot(slotNumber, isOccupied, userType);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildParkingSlot(
      String slotNumber, bool isOccupied, String userType) {
    final color = isOccupied ? Colors.red : Colors.green;
    final statusText = isOccupied ? 'Terisi' : 'Tersedia';

    return GestureDetector(
      onTap: () {
        // Navigasi ke layar konfirmasi pemesanan
        Navigator.pushNamed(
          context,
          '/booking_confirmation',
          arguments: {
            'slotNumber': slotNumber,
            'bookingTime': DateTime.now(),
            'userType': userType,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slotNumber,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              statusText,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
