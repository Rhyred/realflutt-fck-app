import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Alternatif jika menggunakan Firestore

class UserService {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  // Untuk Firestore:
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserProfile({
    required String userId,
    required String name,
    required String plateNumber,
    String? phoneNumber,
    String? photoURL,
    String? rfidTag, // RFID bisa opsional
  }) async {
    try {
      // Menggunakan Realtime Database
      await _usersRef.child(userId).update({
        'name': name,
        'plateNumber': plateNumber,
        'phoneNumber': phoneNumber ?? '',
        'photoURL': photoURL ?? '',
        'rfidTag': rfidTag ?? '', // Simpan string kosong jika null
        'updatedAt': ServerValue
            .timestamp, // Ganti ke updatedAt untuk update selanjutnya
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

  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Buat referensi ke lokasi di Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg');

      // Upload file
      final uploadTask = ref.putFile(imageFile);

      // Tunggu hingga upload selesai
      final snapshot = await uploadTask.whenComplete(() => {});

      // Dapatkan URL download
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // print('Error uploading profile image: $e');
      return null;
    }
  }
}
