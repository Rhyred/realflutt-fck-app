import 'package:firebase_database/firebase_database.dart';

class ParkingService {
  final DatabaseReference _parkingSlotsRef =
      FirebaseDatabase.instance.ref('parking_slots');

  // Simulasikan pembaruan status slot parkir
  Future<void> updateParkingSlotStatus(
      String slotNumber, bool isOccupied) async {
    try {
      await _parkingSlotsRef.child(slotNumber).set(isOccupied);
    } catch (e) {
      // Tangani kesalahan
    }
  }

  // Anda dapat menambahkan metode lain di sini untuk berinteraksi dengan data parkir
  // contoh: mendapatkan status slot tunggal, mendengarkan perubahan untuk slot tertentu, dll.
}
