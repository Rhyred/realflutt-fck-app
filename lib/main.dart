import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ini akan dibuat oleh flutterfire configure (Dibuat oleh flutterfire configure)

import 'package:smart_parking_app/screens/login_signup_screen.dart';
import 'package:smart_parking_app/screens/dashboard_screen.dart';
import 'package:smart_parking_app/screens/booking_confirmation_screen.dart';
import 'package:smart_parking_app/screens/payment_screen.dart';
import 'package:smart_parking_app/screens/about_screen.dart';

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
      title: 'Aplikasi beuki lieur',
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginSignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/booking_confirmation': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null) {
            // Tangani kasus di mana argumen tidak disediakan.
            return const Scaffold(
              body: Center(
                child: Text('Error: Detail pemesanan tidak disediakan.'),
              ),
            );
          }
          return BookingConfirmationScreen(
            slotNumber: args['slotNumber'] as String,
            bookingTime: args['bookingTime'] as DateTime,
            userType: args['userType'] as String,
          );
        },
        '/payment': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null || !args.containsKey('userType')) {
            // Tangani kasus di mana argumen tidak disediakan atau userType hilang.
            return const Scaffold(
              body: Center(
                child: Text(
                    'Error: Tipe pengguna tidak disediakan untuk pembayaran.'),
              ),
            );
          }
          return PaymentScreen(
            userType: args['userType'] as String,
          );
        },
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}
