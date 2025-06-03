import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Assuming you have lottie for animations

class PaymentScreen extends StatefulWidget {
  final String userType; // 'Registered' or 'Guest'

  const PaymentScreen({super.key, required this.userType});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  bool _paymentSuccessful = false;
  bool _isProcessing = false; // Added processing state
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _processPayment() {
    setState(() {
      _isProcessing = true; // Start processing
    });
    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isProcessing = false; // End processing
        _paymentSuccessful = true;
      });
      _animationController.forward();
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Navigate back to dashboard or a confirmation screen
          Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: _paymentSuccessful
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/success_animation.json',
                    controller: _animationController,
                    onLoaded: (composition) {
                      _animationController.duration = composition.duration;
                    },
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 24.0),
                  const Text(
                    'Payment Successful!',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.userType == 'Guest'
                          ? 'Scan QRIS to Pay'
                          : 'Show ID Card',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    if (widget.userType == 'Guest')
                      Container(
                        color: Colors.white,
                        height: 200,
                        // TODO: Display QRIS code here
                        child: Text("QRIS code will be displayed here"),
                      ),
                    if (widget.userType == 'Registered')
                      const Icon(
                        Icons.credit_card, // Placeholder icon for ID card
                        size: 150,
                        color: Colors.white70,
                      ),
                    const SizedBox(height: 40.0),
                    ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : _processPayment, // Disable button when processing
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: _isProcessing // Show loading indicator in button
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              widget.userType == 'Guest'
                                  ? 'I have Paid'
                                  : 'ID Card Checked',
                              style: const TextStyle(fontSize: 18.0),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
