# Aplikasi Parkir Pintar

## Deskripsi

Ini adalah aplikasi parkir pintar yang dibangun dengan Flutter. Aplikasi ini memungkinkan pengguna untuk mencari dan memesan tempat parkir, mengelola pemesanan mereka, dan melakukan pembayaran. Aplikasi ini terintegrasi dengan Firebase untuk otentikasi, penyimpanan data, dan pembaruan waktu nyata.

## Fitur

*   Otentikasi pengguna (masuk/daftar)
*   Dasbor dengan tempat parkir yang tersedia
*   Manajemen pemesanan
*   Integrasi pembayaran
*   Layar tentang dengan informasi aplikasi

## Memulai

### Prasyarat

*   Flutter SDK terpasang
*   Proyek Firebase terkonfigurasi

### Instalasi

1.  Klon repositori:

    ```sh
    git clone https://github.com/nama-pengguna-anda/aplikasi-parkir-pintar.git
    ```
2.  Navigasi ke direktori proyek:

    ```sh
    cd aplikasi-parkir-pintar
    ```
3.  Instal dependensi:

    ```sh
    flutter pub get
    ```

### Konfigurasi

1.  Konfigurasikan Firebase:
    *   Buat proyek Firebase di Firebase Console.
    *   Aktifkan Authentication, Cloud Firestore, dan Cloud Functions.
    *   Unduh file `google-services.json` dan tempatkan di direktori `android/app/`.
    *   Perbarui file `lib/firebase_options.dart` dengan kredensial proyek Firebase Anda.
2.  Perbarui file `android/app/build.gradle.kts` dengan applicationId proyek Firebase Anda.

### Menjalankan Aplikasi

```sh
flutter run
```

## Kontribusi

Kontribusi dipersilakan! Silakan ikuti langkah-langkah berikut:

1.  Fork repositori.
2.  Buat cabang baru untuk fitur atau perbaikan bug Anda.
3.  Buat perubahan Anda dan commit dengan pesan commit yang deskriptif.
4.  Dorong perubahan Anda ke fork Anda.
5.  Kirimkan pull request.

## Lisensi

[MIT](https://opensource.org/licenses/MIT)
