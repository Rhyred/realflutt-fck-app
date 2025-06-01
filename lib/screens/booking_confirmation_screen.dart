import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/services/parking_service.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String slotNumber;
  final DateTime bookingTime;
  final String userType; // 'Registered' or 'Guest'

  const BookingConfirmationScreen({
    Key? key,
    required this.slotNumber,
    required this.bookingTime,
    required this.userType,
  }) : super(key: key);

  @override
  _BookingConfirmationScreenState createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isLoading = false; // Added loading state

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
      // Implement booking logic for registered users using ParkingService
      setState(() {
        _isLoading = true;
      });
      ParkingService().updateParkingSlotStatus(widget.slotNumber, true).then((_) {
        print('Booking confirmed for registered user for slot ${widget.slotNumber}');
        Navigator.popUntil(context, ModalRoute.withName('/dashboard')); // Navigate back to dashboard
      }).catchError((error) {
        // Handle error updating Firebase
        print('Error confirming booking: $error');
        _showErrorSnackbar('Failed to confirm booking: $error');
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
            _buildDetailRow('Booking Time:', widget.bookingTime.toString()), // Format this later
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
                onPressed: _isLoading ? null : _confirmBooking, // Disable button when loading
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading // Show loading indicator in button
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
