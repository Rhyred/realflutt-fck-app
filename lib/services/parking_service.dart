import 'package:firebase_database/firebase_database.dart';

class ParkingService {
  final DatabaseReference _parkingSlotsRef =
      FirebaseDatabase.instance.ref('parking_slots');

  // Simulate updating a parking slot status
  Future<void> updateParkingSlotStatus(String slotNumber, bool isOccupied) async {
    try {
      await _parkingSlotsRef.child(slotNumber).set(isOccupied);
      print('Simulated update: Slot $slotNumber is now ${isOccupied ? "occupied" : "available"}');
    } catch (e) {
      print('Error simulating parking slot update: $e');
      // Handle error
    }
  }

  // You could add more methods here for interacting with parking data
  // e.g., getting a single slot's status, listening to changes for a specific slot, etc.
}
