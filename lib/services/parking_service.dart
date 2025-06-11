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

  // Mendapatkan status slot parkir dari Firebase
  Future<bool> getParkingSlotStatus(String slotNumber) async {
    try {
      final snapshot = await _parkingSlotsRef.child(slotNumber).get();
      if (snapshot.exists) {
        return snapshot.value as bool;
      }
      return false; // Default jika tidak ada data
    } catch (e) {
      // Tangani kesalahan
      return false;
    }
  }

  // Mendengarkan perubahan status slot parkir secara real-time
  Stream<bool> streamParkingSlotStatus(String slotNumber) {
    return _parkingSlotsRef.child(slotNumber).onValue.map((event) {
      if (event.snapshot.exists) {
        return event.snapshot.value as bool;
      }
      return false;
    });
  }
}
