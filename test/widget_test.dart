// Ini adalah tes widget Flutter dasar.
//
// Untuk melakukan interaksi dengan widget dalam tes Anda, gunakan WidgetTester
// utilitas dalam paket flutter_test. Misalnya, Anda dapat mengirim gestur tap dan scroll.
// Anda juga dapat menggunakan WidgetTester untuk menemukan widget anak di pohon widget,
// membaca teks, dan memverifikasi bahwa nilai properti widget sudah benar.

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_parking_app/main.dart';

void main() {
  testWidgets('App title test', (WidgetTester tester) async {
    // Bangun aplikasi kita dan picu frame.
    await tester.pumpWidget(const MyApp()); // Tambahkan kembali const

    // Verifikasi bahwa judul aplikasi sudah benar
    expect(find.text('Smart Parking App'), findsOneWidget);
  });

  // Tambahkan lebih banyak tes sesuai kebutuhan untuk fungsionalitas aplikasi spesifik Anda
}
