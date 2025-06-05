import 'package:flutter/material.dart';
import 'package:smart_parking_app/services/parking_service.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String slotNumber;
  final DateTime bookingTime;
  final String userType; // 'Registered' atau 'Guest'

  const BookingConfirmationScreen({
    super.key,
    required this.slotNumber,
    required this.bookingTime,
    required this.userType,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isLoading = false; // Menambahkan status loading

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _confirmBooking() async {
    if (widget.userType == 'Guest') {
      Navigator.pushNamed(
        context,
        '/payment',
        arguments: {'userType': widget.userType},
      );
    } else {
      // Implementasikan logika pemesanan untuk pengguna terdaftar menggunakan ParkingService
      setState(() {
        _isLoading = true;
      });
      ParkingService()
          .updateParkingSlotStatus(widget.slotNumber, true)
          .then((_) {
        // Pemesanan dikonfirmasi
        if (mounted) {
          Navigator.popUntil(
              context,
              ModalRoute.withName(
                  '/dashboard')); // Navigasi kembali ke dashboard
        }
      }).catchError((error) {
        // Tangani kesalahan saat memperbarui Firebase
        _showErrorSnackbar('Gagal mengonfirmasi pemesanan: $error');
      }).whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Details',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24.0),
            _buildDetailRow('Slot Number:', widget.slotNumber),
            const SizedBox(height: 16.0),
            _buildDetailRow('Booking Time:',
                widget.bookingTime.toString()), // Format ini nanti
            const SizedBox(height: 16.0),
            _buildDetailRow('User Type:', widget.userType),
            const SizedBox(height: 24.0),
            if (widget.userType == 'Registered')
              const Text(
                'Please show your ID Card upon arrival.',
                style: TextStyle(fontSize: 18.0, color: Colors.white70),
              ),
            if (widget.userType == 'Guest')
              const Text(
                'Payment is required via QRIS.',
                style: TextStyle(fontSize: 18.0, color: Colors.white70),
              ),
            const SizedBox(height: 40.0),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _confirmBooking, // Nonaktifkan tombol saat loading
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading // Tampilkan indikator loading di tombol
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Confirm Booking',
                        style: TextStyle(fontSize: 18.0),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18.0,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
