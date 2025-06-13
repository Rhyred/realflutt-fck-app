import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:smart_parking_app/services/parking_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final ParkingService _parkingService = ParkingService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookingHistory();
  }

  Future<void> _loadBookingHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _error = "Pengguna tidak terautentikasi.";
      });
      return;
    }

    try {
      final bookings = await _parkingService.getUserBookings(currentUser.uid);
      // Urutkan booking berdasarkan createdAt descending (terbaru dulu)
      bookings.sort((a, b) {
        DateTime? timeA = DateTime.tryParse(a['createdAt'] ?? '');
        DateTime? timeB = DateTime.tryParse(b['createdAt'] ?? '');
        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1; // nulls last
        if (timeB == null) return -1; // nulls last
        return timeB.compareTo(timeA); // Sort descending
      });
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = "Gagal memuat riwayat booking: ${e.toString()}";
      });
    }
  }

  String _formatDateTime(String? isoDateTime) {
    if (isoDateTime == null) return 'N/A';
    try {
      final DateTime dateTime = DateTime.parse(isoDateTime);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return isoDateTime; // Return original if parsing fails
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'confirmed':
        return 'Terkonfirmasi';
      case 'pending_payment':
        return 'Menunggu Pembayaran';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status ?? 'Tidak Diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Booking'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      );
    }

    if (_bookings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child:
              Text("Tidak ada riwayat booking.", textAlign: TextAlign.center),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookingHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return Card(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: ListTile(
              leading: Icon(Icons.event_note,
                  color: Theme.of(context).colorScheme.primary),
              title: Text('Slot: ${booking['slotId'] ?? 'N/A'}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mulai: ${_formatDateTime(booking['startTime'])}'),
                  Text('Selesai: ${_formatDateTime(booking['endTime'])}'),
                  Text('Status: ${_getStatusText(booking['status'])}'),
                  if (booking['vehiclePlate'] != null)
                    Text('Plat: ${booking['vehiclePlate']}'),
                  Text('Dibuat: ${_formatDateTime(booking['createdAt'])}'),
                ],
              ),
              // isThreeLine: true, // Adjust if needed based on content
            ),
          );
        },
      ),
    );
  }
}
