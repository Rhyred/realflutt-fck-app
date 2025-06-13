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
  // Kembalikan jumlah slot menjadi 4
  final List<String> _slotNumbers = ['Slot 1', 'Slot 2', 'Slot 3', 'Slot 4'];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userType =
        user == null ? 'Guest' : (user.isAnonymous ? 'Guest' : 'Registered');
    final String displayName =
        user?.displayName ?? (userType == "Guest" ? "Tamu" : "Pengguna");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Simpan NavigatorState sebelum async gap
              final navigator = Navigator.of(context);
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                navigator.pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest // Mengganti surfaceVariant
                      .withAlpha((255 * 0.15)
                          .round()), // Opacity disesuaikan agar tidak terlalu gelap
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withAlpha(
                          (255 * 0.5).round()))), // Menggunakan withAlpha
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: $displayName',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userType == 'Guest'
                        ? 'Anda dapat melihat status slot dan melanjutkan ke pembayaran dengan QRIS jika booking.'
                        : 'Selamat datang! Kelola parkir Anda dengan mudah.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Text(
              'Status Slot Parkir',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10.0),
            _buildLegend(context), // Panggil legenda di sini
            const SizedBox(height: 10.0), // Spasi antara legenda dan grid
            Expanded(
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
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary),
                              ),
                              const SizedBox(height: 8),
                              const Text('Memuat status...'),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final isOccupied = snapshot.data ?? false;

                      return _buildParkingSlot(
                          slotNumber, isOccupied, userType);
                    },
                  );
                },
              ),
            ), // Menutup Expanded
          ], // Menutup children dari Column
        ), // Menutup Column
      ), // Menutup Padding
    );
  }

  Widget _buildParkingSlot(
      String slotNumber, bool isSensorOccupied, String userType) {
    // Default colors and text
    String statusText = 'Tersedia';
    Color slotContentColor = Colors.green[700]!; // Warna ikon dan teks status
    Color borderColor = Colors.green[700]!;
    Color sensorIndicatorColor = Colors.green[400]!; // Indikator sensor fisik
    IconData slotIcon = FontAwesomeIcons
        .carAlt; // Ikon mobil default (atau squareParking jika lebih cocok)

    // TODO: Implementasi logika status "Dibooking" yang sebenarnya.
    // Ini memerlukan query ke data booking untuk slot ini pada waktu saat ini.
    // Untuk sekarang, kita akan buat placeholder.
    bool isActuallyBooked =
        false; // Placeholder, ganti dengan logika sebenarnya.
    // Misalnya, jika slotNumber == 'Slot 1', kita anggap dibooking untuk demo.
    if (slotNumber == 'Slot 1' && !isSensorOccupied) {
      // Contoh demo untuk "Dibooking"
      isActuallyBooked = true;
    }

    if (isSensorOccupied) {
      statusText = 'Terisi';
      slotContentColor = Colors.red[700]!;
      borderColor = Colors.red[700]!;
      sensorIndicatorColor = Colors.red[400]!;
      slotIcon = FontAwesomeIcons.car; // Mobil solid
    } else if (isActuallyBooked) {
      statusText = 'Dibooking';
      slotContentColor = Theme.of(context).colorScheme.primary; // Oranye
      borderColor = Theme.of(context).colorScheme.primary;
      // Indikator sensor tetap hijau karena secara fisik kosong
      sensorIndicatorColor = Colors.green[400]!;
      slotIcon = FontAwesomeIcons.carAlt; // Mobil outline atau ikon booking
    } else {
      statusText = 'Tersedia';
      slotContentColor = Colors.green[700]!;
      borderColor = Colors.green[700]!;
      sensorIndicatorColor = Colors.green[400]!;
      slotIcon = FontAwesomeIcons.carAlt; // Mobil outline atau parking
    }

    return GestureDetector(
      onTap: () {
        // Hanya bisa diklik jika tersedia atau (nantinya) jika dibooking oleh pengguna sendiri untuk opsi lain
        if (statusText == 'Tersedia' ||
            (statusText == 'Dibooking' /* && isBookedByCurrentUser */)) {
          Navigator.pushNamed(
            context,
            '/booking_confirmation',
            arguments: {
              'slotNumber': slotNumber,
              'startTime': DateTime.now(),
              'endTime': DateTime.now().add(const Duration(hours: 1)),
              'userType': userType,
            },
          );
          _logParkingSlotUsage(slotNumber); // Panggil kembali log
        } else if (statusText == 'Terisi') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Slot $slotNumber sedang terisi.'),
                backgroundColor: Colors.red),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background kartu selalu putih
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withAlpha(50),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 6,
              right: 6,
              child: CircleAvatar(
                radius: 7,
                backgroundColor: sensorIndicatorColor,
                // border: Border.all(color: Colors.white, width: 1) // Opsional border putih
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(slotIcon, size: 40.0, color: slotContentColor),
                    const SizedBox(height: 12.0),
                    Text(
                      statusText,
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: slotContentColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      slotNumber,
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                    ),
                  ],
                ),
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

  Widget _buildLegend(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 8.0), // Adjusted padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(context, Colors.green[700]!, 'Tersedia'),
          _legendItem(
              context,
              Theme.of(context)
                  .colorScheme
                  .primary
                  .withAlpha((255 * 0.4).round()),
              'Dibooking'), // Warna oranye dari tema
          _legendItem(context, Colors.red[700]!, 'Terisi'),
        ],
      ),
    );
  }

  Widget _legendItem(BuildContext context, Color color, String text) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color), // Ukuran lebih kecil
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
