import 'package:firebase_database/firebase_database.dart';
import 'dart:async'; // Untuk Futurer

class ParkingService {
  final DatabaseReference _parkingSlotsRef =
      FirebaseDatabase.instance.ref('parking_slots');
  final DatabaseReference _bookingsRef =
      FirebaseDatabase.instance.ref('bookings');

  // --- Metode Terkait Status Slot Fisik (dari ESP32) ---

  // Simulasikan pembaruan status slot parkir (lebih baik ini dihandle ESP32)
  // Fungsi ini mungkin tidak lagi relevan jika ESP32 yang utama update status fisik
  Future<void> updateParkingSlotStatus(
      String slotNumber, bool isOccupied) async {
    try {
      await _parkingSlotsRef.child(slotNumber).set(isOccupied);
      // print('ParkingService: Slot $slotNumber status updated to $isOccupied');
    } catch (e) {
      // print('Error updating parking slot status: $e');
      throw Exception('Failed to update parking slot status: $e');
    }
  }

  // Mendapatkan status slot parkir fisik dari Firebase
  Future<bool> getParkingSlotStatus(String slotNumber) async {
    try {
      final snapshot = await _parkingSlotsRef.child(slotNumber).get();
      if (snapshot.exists && snapshot.value != null) {
        return snapshot.value as bool;
      }
      return false; // Default jika tidak ada data atau null
    } catch (e) {
      // print('Error getting parking slot status: $e');
      return false;
    }
  }

  // Mendengarkan perubahan status slot parkir fisik secara real-time
  Stream<bool> streamParkingSlotStatus(String slotNumber) {
    return _parkingSlotsRef.child(slotNumber).onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        return event.snapshot.value as bool;
      }
      return false;
    });
  }

  // --- Metode Terkait Booking ---

  /// Memeriksa apakah slot tersedia untuk dibooking pada rentang waktu tertentu.
  /// Hanya memeriksa berdasarkan data booking yang ada, tidak status fisik real-time.
  Future<bool> isSlotAvailableForBooking(
      String slotId, DateTime desiredStartTime, DateTime desiredEndTime) async {
    try {
      final query = _bookingsRef.orderByChild('slotId').equalTo(slotId);
      final snapshot = await query.get();

      if (snapshot.exists && snapshot.value != null) {
        final bookings = Map<String, dynamic>.from(snapshot.value as Map);
        for (var bookingEntry in bookings.values) {
          final booking = Map<String, dynamic>.from(bookingEntry as Map);

          // Abaikan booking yang dibatalkan
          if (booking['status'] == 'cancelled') {
            continue;
          }

          final existingStartTime =
              DateTime.parse(booking['startTime'] as String);
          final existingEndTime = DateTime.parse(booking['endTime'] as String);

          // Periksa tumpang tindih waktu
          // (desiredStart < existingEnd) and (desiredEnd > existingStart)
          if (desiredStartTime.isBefore(existingEndTime) &&
              desiredEndTime.isAfter(existingStartTime)) {
            // print(
            // 'Slot $slotId tidak tersedia: Tumpang tindih dengan booking yang ada.');
            return false; // Ada tumpang tindih
          }
        }
      }
      // print(
      // 'Slot $slotId tersedia untuk booking pada rentang waktu yang diinginkan.');
      return true; // Tidak ada tumpang tindih
    } catch (e) {
      // print('Error checking slot availability: $e');
      return false; // Anggap tidak tersedia jika ada error
    }
  }

  /// Membuat booking baru jika slot tersedia.
  /// bookingData harus berisi: userId, slotId, startTime (ISO8601 String),
  /// endTime (ISO8601 String), status, vehiclePlate (opsional).
  Future<String?> createBooking(Map<String, dynamic> bookingData) async {
    if (bookingData['slotId'] == null ||
        bookingData['startTime'] == null ||
        bookingData['endTime'] == null) {
      // print(
      // 'Error: Data booking tidak lengkap (slotId, startTime, endTime diperlukan).');
      return null;
    }

    final String slotId = bookingData['slotId'];
    final DateTime desiredStartTime = DateTime.parse(bookingData['startTime']);
    final DateTime desiredEndTime = DateTime.parse(bookingData['endTime']);

    // 1. Periksa ketersediaan berdasarkan booking yang ada
    bool available = await isSlotAvailableForBooking(
        slotId, desiredStartTime, desiredEndTime);
    if (!available) {
      // print(
      // 'Gagal membuat booking: Slot $slotId tidak tersedia pada waktu yang diminta.');
      return null; // Slot tidak tersedia
    }

    // (Opsional) 2. Periksa status fisik slot jika booking untuk "sekarang"
    // Ini bisa lebih kompleks, misalnya jika slot kosong tapi ada booking akan mulai sebentar lagi.
    // Untuk saat ini, kita fokus pada konflik booking.
    // bool physicalStatus = await getParkingSlotStatus(slotId);
    // if (physicalStatus && desiredStartTime.isBefore(DateTime.now().add(Duration(minutes: 5)))) {
    //   print('Gagal membuat booking: Slot $slotId sedang terisi secara fisik.');
    //   return null;
    // }

    try {
      final newBookingRef = _bookingsRef.push();
      await newBookingRef.set(bookingData);
      // print('Booking berhasil dibuat dengan ID: ${newBookingRef.key}');
      return newBookingRef.key; // Kembalikan ID booking baru
    } catch (e) {
      // print('Error creating booking: $e');
      return null;
    }
  }

  /// Mendapatkan semua booking untuk slot tertentu.
  Future<List<Map<String, dynamic>>> getBookingsForSlot(String slotId) async {
    List<Map<String, dynamic>> bookingsList = [];
    try {
      final query = _bookingsRef.orderByChild('slotId').equalTo(slotId);
      final snapshot = await query.get();
      if (snapshot.exists && snapshot.value != null) {
        final bookingsData = Map<String, dynamic>.from(snapshot.value as Map);
        bookingsData.forEach((key, value) {
          final booking = Map<String, dynamic>.from(value as Map);
          booking['id'] = key; // Tambahkan ID booking ke data
          bookingsList.add(booking);
        });
      }
    } catch (e) {
      // print('Error getting bookings for slot $slotId: $e');
    }
    return bookingsList;
  }

  /// Mendapatkan semua booking untuk pengguna tertentu.
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    List<Map<String, dynamic>> bookingsList = [];
    try {
      final query = _bookingsRef.orderByChild('userId').equalTo(userId);
      final snapshot = await query.get();
      if (snapshot.exists && snapshot.value != null) {
        final bookingsData = Map<String, dynamic>.from(snapshot.value as Map);
        bookingsData.forEach((key, value) {
          final booking = Map<String, dynamic>.from(value as Map);
          booking['id'] = key; // Tambahkan ID booking ke data
          bookingsList.add(booking);
        });
      }
    } catch (e) {
      // print('Error getting user bookings for $userId: $e');
    }
    return bookingsList;
  }

  // Anda dapat menambahkan metode lain di sini, seperti updateBookingStatus, cancelBooking, dll.
}
