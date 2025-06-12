import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ini akan dibuat oleh flutterfire configure (Dibuat oleh flutterfire configure)

import 'package:smart_parking_app/screens/login_signup_screen.dart';
import 'package:smart_parking_app/screens/dashboard_screen.dart';
import 'package:smart_parking_app/screens/booking_confirmation_screen.dart';
import 'package:smart_parking_app/screens/payment_screen.dart';
import 'package:smart_parking_app/screens/about_screen.dart';
import 'package:smart_parking_app/screens/auth_wrapper.dart'; // Import AuthWrapper
import 'package:smart_parking_app/screens/account_settings_screen.dart'; // Import AccountSettingsScreen
import 'package:smart_parking_app/screens/main_navigation_screen.dart'; // Import MainNavigationScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Parkir Cerdas', // Judul disesuaikan
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.indigo,
          secondary: Colors.amber,
          surface: Colors.grey[800]!,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.indigo,
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.amber,
          ),
        ),
      ),
      // initialRoute: '/login', // Diganti dengan home
      home: const AuthWrapper(), // Gunakan AuthWrapper sebagai halaman utama
      routes: {
        // Rute '/login' dan '/dashboard' masih bisa berguna untuk navigasi eksplisit
        // jika diperlukan, meskipun AuthWrapper menangani tampilan awal.
        '/login': (context) => const LoginSignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/booking_confirmation': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null) {
            return const Scaffold(
              body: Center(
                child: Text('Error: Detail pemesanan tidak disediakan.'),
              ),
            );
          }
          // Pastikan argumen yang diterima sekarang adalah startTime dan endTime
          if (args['slotNumber'] == null ||
              args['startTime'] == null ||
              args['endTime'] == null ||
              args['userType'] == null) {
            return const Scaffold(
              body: Center(
                child: Text(
                    'Error: Detail pemesanan tidak lengkap (slot, waktu mulai/selesai, atau tipe pengguna).'),
              ),
            );
          }
          return BookingConfirmationScreen(
            slotNumber: args['slotNumber'] as String,
            startTime: args['startTime'] as DateTime, // Menggunakan startTime
            endTime: args['endTime'] as DateTime, // Menggunakan endTime
            userType: args['userType'] as String,
          );
        },
        '/payment': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null || !args.containsKey('userType')) {
            return const Scaffold(
              body: Center(
                child: Text(
                    'Error: Tipe pengguna tidak disediakan untuk pembayaran.'),
              ),
            );
          }
          // Anda mungkin juga ingin meneruskan bookingId atau detail lain ke PaymentScreen
          return PaymentScreen(
            userType: args['userType'] as String,
            // bookingId: args['bookingId'] as String?, // Contoh jika PaymentScreen memerlukan bookingId
            // slotId: args['slotId'] as String?, // Contoh
          );
        },
        '/about': (context) => const AboutScreen(),
        '/account_settings': (context) =>
            const AccountSettingsScreen(), // Tambahkan rute untuk AccountSettingsScreen
        '/main_navigation': (context) =>
            const MainNavigationScreen(), // Tambahkan rute
      },
    );
  }
}
