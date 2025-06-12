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
    // final DateFormat dateTimeFormatter = DateFormat('dd MMM yyyy, HH:mm'); // Dihapus karena tidak digunakan
    final Duration bookingDuration =
        widget.endTime.difference(widget.startTime);
    String durationText = '';
    if (bookingDuration.inHours > 0) {
      durationText += '${bookingDuration.inHours} jam ';
    }
    if (bookingDuration.inMinutes % 60 > 0) {
      durationText += '${bookingDuration.inMinutes % 60} menit';
    }
    if (durationText.isEmpty) {
      durationText = 'Kurang dari 1 menit';
    }

    final Color primaryColor = Theme.of(context).colorScheme.primary;
    // Menggunakan Color.alphaBlend untuk alternatif withOpacity jika ada masalah presisi,
    // atau cara lain yang direkomendasikan jika .withValues() lebih cocok.
    // Untuk kesederhanaan, jika .withOpacity() masih berfungsi dan presisi tidak kritis, bisa dipertahankan.
    // Namun, untuk mengikuti saran lint, kita bisa menggunakan alphaBlend atau membuat warna baru.
    // Contoh dengan alphaBlend (membutuhkan warna dasar untuk di-blend):
    // final Color lightPurpleBackground = Color.alphaBlend(primaryColor.withAlpha((255 * 0.1).round()), Colors.white);
    // Atau cara yang lebih umum dan seringkali cukup:
    final Color lightPurpleBackground =
        primaryColor.withAlpha((255 * 0.1).round());

    return Scaffold(
      // AppBar dan backgroundColor akan mengambil dari tema
      appBar: AppBar(
        title: const Text('Konfirmasi Booking'),
        // backgroundColor sudah diatur oleh tema
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Pemesanan', // Sesuai desain "Please confirm your booking details..."
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.normal,
                    fontSize: 20),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Silakan konfirmasi detail pemesanan Anda dan lanjutkan.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 24.0),
              // ID #XXXX (Placeholder atau tampilkan setelah booking berhasil di layar lain)
              // Untuk saat ini, kita tampilkan detail yang ada
              _buildDetailRow('Nomor Slot:', widget.slotNumber, context),
              const SizedBox(height: 16.0),
              _buildDetailRow('Tanggal:',
                  DateFormat('dd MMMM yyyy').format(widget.startTime), context),
              const SizedBox(height: 16.0),
              _buildDetailRow('Waktu Mulai:',
                  DateFormat('HH:mm').format(widget.startTime), context),
              const SizedBox(height: 16.0),
              _buildDetailRow('Durasi:', durationText.trim(), context),
              // _buildDetailRow('Waktu Selesai:', dateTimeFormatter.format(widget.endTime), context),
              const SizedBox(height: 16.0),
              _buildDetailRow('Tipe Pengguna:', widget.userType, context),
              const SizedBox(height: 32.0),

              if (widget.userType == 'Registered')
                _buildConfirmationButton(
                  context: context,
                  icon: Icons.credit_card, // Mengganti ikon ID card
                  text: 'Konfirmasi (Identitas Terdaftar)',
                  onPressed: _isLoading ? null : _confirmBooking,
                  backgroundColor: lightPurpleBackground,
                  foregroundColor: primaryColor,
                ),

              if (widget.userType == 'Guest')
                _buildConfirmationButton(
                  context: context,
                  icon: Icons.qr_code_scanner, // Ikon QR
                  text: 'Lanjutkan ke Pembayaran QR',
                  onPressed: _isLoading ? null : _confirmBooking,
                  backgroundColor: lightPurpleBackground,
                  foregroundColor: primaryColor,
                ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(text, style: const TextStyle(fontSize: 16)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Sesuai desain
            side: BorderSide(
                color: foregroundColor.withAlpha((255 * 0.5).round())),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
