import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Asumsi Anda memiliki lottie untuk animasi

class PaymentScreen extends StatefulWidget {
  final String userType; // 'Registered' atau 'Guest'

  const PaymentScreen({super.key, required this.userType});

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  bool _paymentSuccessful = false;
  bool _isProcessing = false; // Menambahkan status pemrosesan
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
      _isProcessing = true; // Mulai pemrosesan
    });
    // Simulasikan pemrosesan pembayaran
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isProcessing = false; // Akhiri pemrosesan
        _paymentSuccessful = true;
      });
      _animationController.forward();
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Navigasi kembali ke dashboard atau layar konfirmasi
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
                        // TODO: Tampilkan kode QRIS di sini
                        child: const Text("QRIS code will be displayed here"),
                      ),
                    if (widget.userType == 'Registered')
                      const Icon(
                        Icons
                            .credit_card, // Ikon placeholder untuk kartu identitas
                        size: 150,
                        color: Colors.white70,
                      ),
                    const SizedBox(height: 40.0),
                    ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : _processPayment, // Nonaktifkan tombol saat memproses
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child:
                          _isProcessing // Tampilkan indikator loading di tombol
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
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
