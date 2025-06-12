import 'package:flutter/material.dart';
import 'package:smart_parking_app/services/parking_service.dart';
// Import intl untuk formatting tanggal jika diperlukan
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:uuid/uuid.dart'; // Import UUID package

class BookingConfirmationScreen extends StatefulWidget {
  final String slotNumber;
  final DateTime startTime; // Mengganti bookingTime menjadi startTime
  final DateTime endTime; // Menambahkan endTime
  final String userType; // 'Registered' atau 'Guest'

  const BookingConfirmationScreen({
    super.key,
    required this.slotNumber,
    required this.startTime,
    required this.endTime,
    required this.userType,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isLoading = false;
  final ParkingService _parkingService = ParkingService();
  // Tambahkan TextEditingController jika ingin input vehiclePlate
  // final TextEditingController _vehiclePlateController = TextEditingController();

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return; // Check if the widget is still in the tree
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _confirmBooking() async {
    setState(() {
      _isLoading = true;
    });

    String? actualUserId;
    final User? currentUser = FirebaseAuth.instance.currentUser;
    const uuid = Uuid(); // Membuat instance Uuid

    if (widget.userType == 'Registered') {
      if (currentUser != null) {
        actualUserId = currentUser.uid;
      } else {
        if (mounted) {
          _showSnackbar('Sesi tidak valid. Silakan login kembali.',
              isError: true);
          setState(() {
            _isLoading = false;
          });
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
        return;
      }
    } else {
      // Guest User
      actualUserId = 'guest_${uuid.v4()}'; // Menghasilkan UUID v4 untuk tamu
    }

    // Contoh plat nomor, bisa diambil dari _vehiclePlateController.text jika ada input field
    String vehiclePlate =
        "B1234XYZ"; // Anda bisa menambahkan input field untuk ini

    Map<String, dynamic> bookingData = {
      'userId': actualUserId, // Menggunakan actualUserId
      'slotId': widget.slotNumber,
      'startTime': widget.startTime.toIso8601String(),
      'endTime': widget.endTime.toIso8601String(),
      'status': widget.userType == 'Guest' ? 'pending_payment' : 'confirmed',
      'vehiclePlate': vehiclePlate,
      'createdAt': DateTime.now()
          .toIso8601String(), // Tambahkan timestamp pembuatan booking
    };

    try {
      String? bookingId = await _parkingService.createBooking(bookingData);
      if (!mounted) return;

      if (bookingId != null) {
        _showSnackbar('Booking berhasil dikonfirmasi dengan ID: $bookingId');
        if (widget.userType == 'Guest') {
          // Navigasi ke pembayaran dengan membawa bookingId jika perlu
          Navigator.pushNamed(
            context,
            '/payment',
            arguments: {
              'userType': widget.userType,
              'bookingId': bookingId,
              'slotId': widget.slotNumber
            },
          );
        } else {
          // Navigasi kembali ke dashboard untuk pengguna terdaftar
          Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
        }
      } else {
        _showSnackbar(
            'Gagal membuat booking. Slot mungkin tidak tersedia atau terjadi kesalahan.',
            isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackbar('Terjadi kesalahan: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format tanggal dan waktu agar lebih mudah dibaca
    final DateFormat dateTimeFormatter = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Booking'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Booking',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24.0),
              _buildDetailRow('Nomor Slot:', widget.slotNumber),
              const SizedBox(height: 16.0),
              _buildDetailRow(
                  'Waktu Mulai:', dateTimeFormatter.format(widget.startTime)),
              const SizedBox(height: 16.0),
              _buildDetailRow(
                  'Waktu Selesai:', dateTimeFormatter.format(widget.endTime)),
              const SizedBox(height: 16.0),
              _buildDetailRow('Tipe Pengguna:', widget.userType),
              const SizedBox(height: 24.0),
              // Jika ingin input plat nomor:
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 8.0),
              //   child: TextFormField(
              //     // controller: _vehiclePlateController,
              //     style: const TextStyle(color: Colors.white),
              //     decoration: const InputDecoration(
              //       labelText: 'Plat Nomor Kendaraan (Opsional)',
              //       labelStyle: TextStyle(color: Colors.white70),
              //       enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
              //       focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.indigo)),
              //       hintText: 'Contoh: B 1234 XYZ',
              //       hintStyle: TextStyle(color: Colors.white30),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 16.0), // Sesuaikan spacing jika ada input plat
              if (widget.userType == 'Registered')
                const Text(
                  'Mohon tunjukkan kartu identitas Anda saat tiba.',
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white70), // Ukuran font disesuaikan
                ),
              if (widget.userType == 'Guest')
                const Text(
                  'Pembayaran diperlukan melalui QRIS.',
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white70), // Ukuran font disesuaikan
                ),
              const SizedBox(height: 40.0),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          // Indikator loading lebih rapi
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Konfirmasi Booking', // Teks disesuaikan
                          style: TextStyle(fontSize: 18.0),
                        ),
                ),
              ),
            ],
          ),
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
        Expanded(
          // Tambahkan Expanded agar value tidak overflow jika panjang
          child: Text(
            value,
            textAlign: TextAlign.end, // Ratakan teks value ke kanan
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis, // Cegah overflow dengan ellipsis
          ),
        ),
      ],
    );
  }
}
