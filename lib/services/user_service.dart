import 'package:firebase_database/firebase_database.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Alternatif jika menggunakan Firestore

class UserService {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  // Untuk Firestore:
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserProfile({
    required String userId,
    required String name,
    required String plateNumber,
    String? rfidTag, // RFID bisa opsional
  }) async {
    try {
      // Menggunakan Realtime Database
      await _usersRef.child(userId).set({
        'name': name,
        'plateNumber': plateNumber,
        'rfidTag': rfidTag ?? '', // Simpan string kosong jika null
        'createdAt': ServerValue
            .timestamp, // Timestamp server untuk kapan profil dibuat/diupdate
      });

      // Alternatif menggunakan Firestore:
      // await _firestore.collection('users').doc(userId).set({
      //   'name': name,
      //   'plateNumber': plateNumber,
      //   'rfidTag': rfidTag ?? '',
      //   'createdAt': FieldValue.serverTimestamp(),
      // }, SetOptions(merge: true)); // merge: true untuk update jika dokumen sudah ada
      // print('User profile for $userId updated in Realtime Database.'); // Komentari print
    } catch (e) {
      // print('Error updating user profile: $e'); // Komentari print
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final snapshot = await _usersRef.child(userId).get();
      if (snapshot.exists && snapshot.value != null) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      // print('Error getting user profile: $e'); // Komentari print
      return null;
    }
  }
}
