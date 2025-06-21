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
import 'package:smart_parking_app/theme_provider.dart'; // Import ThemeNotifier
import 'package:smart_parking_app/screens/booking_history_screen.dart'; // Import BookingHistoryScreen
import 'package:smart_parking_app/screens/complete_profile_screen.dart'; // Import CompleteProfileScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      const MyApp()); // Tambahkan kembali const karena constructor MyApp sudah const
}

// Untuk menyediakan ThemeNotifier, kita bisa menggunakan Provider package,
// atau InheritedWidget, atau meneruskannya.
// Untuk kesederhanaan awal, kita akan buat MyApp StatefulWidget dan kelola notifier di sana.
// Kemudian kita akan lihat cara terbaik untuk mengaksesnya dari AccountSettingsScreen.

class MyApp extends StatefulWidget {
  // Tambahkan const jika tidak ada parameter yang mencegahnya
  const MyApp({super.key});

  // Untuk mengakses notifier dari luar jika diperlukan (misalnya dari AccountSettingsScreen)
  // Ini bukan cara terbaik, lebih baik pakai Provider atau InheritedWidget.
  // Tapi untuk langkah ini, kita akan coba cara sederhana dulu.
  // static _MyAppState? of(BuildContext context) => // Dihapus karena _MyAppState private
  //     context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeNotifier _themeNotifier;

  @override
  void initState() {
    super.initState();
    // Default ke tema gelap
    _themeNotifier = ThemeNotifier(ThemeMode.dark);
    _themeNotifier.addListener(() {
      if (mounted) {
        setState(() {
          // State MyApp perlu di-rebuild untuk memperbarui MaterialApp dengan themeMode baru
        });
      }
    });
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  void changeTheme(ThemeMode themeMode) {
    _themeNotifier.setThemeMode(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange =
        Color(0xFFFF9800); // Warna Oranye Utama (Material Orange 500)

    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryOrange,
        secondary: Colors.deepOrangeAccent, // Contoh warna sekunder
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        titleLarge:
            TextStyle(color: primaryOrange, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: const BorderSide(color: primaryOrange, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryOrange),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryOrange,
        unselectedItemColor: Colors.grey,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryOrange, width: 1.5),
        ),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor:
          primaryOrange, // Oranye tetap bisa jadi primary di dark theme
      scaffoldBackgroundColor: Colors.grey[900], // Background gelap
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850], // AppBar lebih gelap
        foregroundColor: primaryOrange, // Teks oranye di AppBar gelap
        elevation: 0,
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryOrange,
        secondary: Colors.orangeAccent, // Warna sekunder untuk dark theme
        surface: Colors.grey[800]!,
        onPrimary: Colors.black, // Teks hitam di atas tombol oranye
        onSecondary: Colors.black,
        onSurface: Colors.white70, // Teks lebih terang di atas surface gelap
        error: Colors.red,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white70),
        titleLarge:
            TextStyle(color: primaryOrange, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor:
              Colors.black, // Teks hitam agar kontras di tombol oranye
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: const BorderSide(color: primaryOrange, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryOrange),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.grey[850], // BottomNav lebih gelap
        selectedItemColor: primaryOrange,
        unselectedItemColor: Colors.grey[400],
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[800],
        labelStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryOrange, width: 1.5),
        ),
      ),
    );

    // Untuk saat ini, kita akan set default ke lightTheme
    // Implementasi switch akan ditambahkan kemudian
    return MaterialApp(
      title: 'Smart_Park By NRP', // Nama aplikasi diubah
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeNotifier.themeMode, // Gunakan themeMode dari notifier
      home: AuthWrapper(themeNotifier: _themeNotifier), // Teruskan notifier
      routes: {
        '/login': (context) => const LoginSignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        // Modifikasi rute AccountSettingsScreen untuk menerima ThemeNotifier
        // Ini adalah cara sederhana, Provider/InheritedWidget lebih baik untuk skala besar
        '/account_settings': (context) => const AccountSettingsScreen(),
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
        // '/account_settings': (context) => AccountSettingsScreen( // Dihapus karena sudah ada di atas
        //     themeNotifier: _themeNotifier),
        '/main_navigation': (context) => MainNavigationScreen(
            themeNotifier: _themeNotifier), // Teruskan notifier
        '/booking_history': (context) =>
            const BookingHistoryScreen(), // Tambahkan rute
        '/complete_profile': (context) =>
            const CompleteProfileScreen(), // Tambahkan rute
      },
    );
  }
}
