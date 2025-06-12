import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_parking_app/services/parking_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final ParkingService _parkingService = ParkingService();
  final List<String> _slotNumbers = ['Slot 1', 'Slot 2', 'Slot 3', 'Slot 4'];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userType = user == null ? 'Guest' : 'Registered';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Parking Dashboard'),
        backgroundColor: Colors.black,
        automaticallyImplyLeading:
            false, // Sembunyikan tombol kembali jika ini adalah tab utama
        // actions: [ // Dihapus karena settings pindah ke BottomNav
        //   IconButton(
        //     icon: const Icon(Icons.settings),
        //     onPressed: () {
        //       Navigator.pushNamed(context, '/account_settings');
        //     },
        //   ),
        // ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.0,
          ),
          itemCount: _slotNumbers.length,
          itemBuilder: (context, index) {
            final slotNumber = _slotNumbers[index];

            return StreamBuilder<bool>(
              stream: _parkingService.streamParkingSlotStatus(slotNumber),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final isOccupied = snapshot.data ?? false;

                return _buildParkingSlot(slotNumber, isOccupied, userType);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildParkingSlot(
      String slotNumber, bool isOccupied, String userType) {
    final color = isOccupied ? Colors.indigoAccent : Colors.green;
    final statusText = isOccupied ? 'Terisi' : 'Tersedia';

    return GestureDetector(
      onTap: () {
        // Navigasi ke layar konfirmasi pemesanan
        Navigator.pushNamed(
          context,
          '/booking_confirmation',
          arguments: {
            'slotNumber': slotNumber,
            'startTime': DateTime.now(), // Changed from bookingTime
            'endTime': DateTime.now()
                .add(const Duration(hours: 1)), // Added default endTime
            'userType': userType,
          },
        );

        // Catat penggunaan slot parkir
        _logParkingSlotUsage(slotNumber);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slotNumber,
              style: const TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            Icon(
              isOccupied
                  ? FontAwesomeIcons.car
                  : FontAwesomeIcons.squareParking,
              size: 40.0,
              color: Colors.white,
            ),
            const SizedBox(height: 8.0),
            Text(
              statusText,
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logParkingSlotUsage(String slotNumber) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';
    final usageRef = FirebaseDatabase.instance
        .ref('parking_slot_usage')
        .child(slotNumber)
        .child(userId)
        .push();

    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedTimestamp = formatter.format(now);

    usageRef.set({
      'timestamp': formattedTimestamp,
    });
  }
}
