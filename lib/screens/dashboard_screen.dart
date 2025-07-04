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
        title: const Text('Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
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
            _buildEspStatusBanner(),
            const SizedBox(height: 16),
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
                    'Masuk Sebagai: $displayName',
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
            Center(
              child: Text(
                'Status Slot Parkir',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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

                  return StreamBuilder<SlotState>(
                    stream: _parkingService.streamSlotState(slotNumber),
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

                      // Gunakan status default jika tidak ada data
                      final slotState = snapshot.data ??
                          SlotState(isOccupied: false, isBooked: false);

                      return _buildParkingSlot(slotNumber, slotState, userType);
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
      String slotNumber, SlotState slotState, String userType) {
    // Default colors and text
    String statusText;
    Color slotContentColor;
    Color borderColor;
    Color sensorIndicatorColor;
    IconData slotIcon;

    // Logika baru berdasarkan SlotState
    if (slotState.isOccupied) {
      statusText = 'Terisi';
      slotContentColor = Colors.red[700]!;
      borderColor = Colors.red[700]!;
      sensorIndicatorColor = Colors.red[400]!;
      slotIcon = FontAwesomeIcons.car; // Mobil solid
    } else if (slotState.isBooked) {
      statusText = 'Dibooking';
      slotContentColor = Theme.of(context).colorScheme.primary; // Oranye
      borderColor = Theme.of(context).colorScheme.primary;
      // Indikator sensor tetap hijau karena secara fisik kosong
      sensorIndicatorColor = Colors.green[400]!;
      slotIcon = FontAwesomeIcons.solidClock; // Ikon jam untuk booking
    } else {
      statusText = 'Tersedia';
      slotContentColor = Colors.green[700]!;
      borderColor = Colors.green[700]!;
      sensorIndicatorColor = Colors.green[400]!;
      slotIcon = FontAwesomeIcons.carRear; // Mobil outline atau parking
    }

    return GestureDetector(
      onTap: () {
        if (statusText == 'Tersedia') {
          _showSlotDetailsDialog(slotNumber, userType);
        } else if (statusText == 'Terisi') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Slot $slotNumber sedang terisi.'),
                backgroundColor: Colors.red),
          );
        } else if (statusText == 'Dibooking') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Slot $slotNumber sudah dibooking.'),
                backgroundColor: Theme.of(context).colorScheme.primary),
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

  String _getSlotLocation(String slotNumber) {
    switch (slotNumber) {
      case 'Slot 1':
        return 'Lantai A, No. 1';
      case 'Slot 2':
        return 'Lantai A, No. 2';
      case 'Slot 3':
        return 'Lantai B, No. 1';
      case 'Slot 4':
        return 'Lantai B, No. 2';
      default:
        return 'Lokasi tidak diketahui';
    }
  }

  void _showSlotDetailsDialog(String slotNumber, String userType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final now = DateTime.now();
        final location = _getSlotLocation(slotNumber);

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Detail Slot Parkir',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildDetailRowDialog('Nomor Slot:', slotNumber),
              _buildDetailRowDialog('Lokasi:', location),
              _buildDetailRowDialog(
                  'Tanggal:', DateFormat('d MMMM yyyy').format(now)),
              _buildDetailRowDialog('Waktu:', DateFormat('HH:mm').format(now)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Pesan Sekarang'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog first
                Navigator.pushNamed(
                  context,
                  '/booking_confirmation',
                  arguments: {
                    'slotNumber': slotNumber,
                    'startTime': now,
                    'endTime': now.add(const Duration(hours: 1)),
                    'userType': userType,
                  },
                );
                _logParkingSlotUsage(slotNumber);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRowDialog(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildEspStatusBanner() {
    return StreamBuilder<bool>(
      stream: _parkingService.streamEsp32Status(),
      builder: (context, snapshot) {
        // Tampilkan banner loading atau kosong saat data pertama belum tiba
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink(); // Atau widget loading kecil
        }

        final bool isOnline = snapshot.data ?? false;
        final Color bannerColor =
            isOnline ? Colors.green.shade100 : Colors.amber.shade100;
        final Color contentColor =
            isOnline ? Colors.green.shade800 : Colors.amber.shade800;
        final IconData icon = isOnline ? Icons.check_circle : Icons.warning;
        final String text = isOnline
            ? 'Sistem Parkir Online'
            : 'Sistem Offline: Data mungkin tidak akurat.';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bannerColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Icon(icon, color: contentColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                      color: contentColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
