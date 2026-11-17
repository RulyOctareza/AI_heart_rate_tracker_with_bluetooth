<p align="center">
  <img src="docs/preview/hero.png" alt="Heart Rate Tracker — ilustrasi aplikasi pemantau detak jantung BLE" width="100%">
</p>

<h1 align="center">AI Heart Rate Tracker</h1>

<p align="center">
  <b>Pantau detak jantung dari sensor Bluetooth langsung di ponsel.</b><br>
  Scan BLE · grafik live · riwayat tersimpan lokal
</p>

<p align="center">
  <a href="https://flutter.dev"><img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white"></a>
  <img alt="BLoC" src="https://img.shields.io/badge/State-BLoC-2496ED">
  <a href="https://pub.dev/packages/flutter_blue_plus"><img alt="BLE" src="https://img.shields.io/badge/BLE-flutter__blue__plus-0082FC"></a>
  <img alt="SQLite" src="https://img.shields.io/badge/Storage-SQLite-00599C?logo=sqlite&logoColor=white">
</p>

---

## ✨ Preview

<p align="center">
  <img src="docs/preview/hero.png" alt="Mockup gelap Heart Rate Tracker" width="90%">
</p>

> **Catatan:** gambar di atas adalah *ilustrasi konsep*, bukan screenshot asli.

---

## 📖 Tentang

Aplikasi Flutter yang terhubung ke sensor detak jantung Bluetooth Low Energy (BLE),
menampilkan BPM secara live dalam grafik, lalu menyimpan riwayat pengukuran ke SQLite
supaya bisa ditinjau kapan saja.

---

## 🌟 Fitur

- 🔍 **Scan & connect** perangkat BLE (`flutter_blue_plus`)
- ❤️ **Monitoring BPM** real-time dengan grafik (`fl_chart`)
- 📈 **Riwayat pengukuran** tersimpan lokal di SQLite (`sqflite`)
- 🧭 **Navigasi** dengan GoRouter
- 🔐 **Izin Bluetooth & lokasi** lewat `permission_handler`
- 🎨 Tema dan format tanggal Indonesia (`intl`)

---

## 🛠️ Tech Stack

| Area | Pilihan |
|---|---|
| Framework | Flutter |
| State management | flutter_bloc |
| Bluetooth | `flutter_blue_plus` |
| Grafik | `fl_chart` |
| Database lokal | `sqflite` |
| Routing | GoRouter |

---

## 🧱 Struktur

```text
lib/
├── data/          # Model, datasource, repository
├── domain/        # Entity & use case
├── presentation/  # Halaman: scanner, monitor, history
│   ├── ble_monitor_bloc.dart
│   ├── scanner_page.dart
│   ├── monitor_page.dart
│   └── history_page.dart
└── main.dart
```

---

## 🚀 Menjalankan

```bash
flutter pub get
flutter run
```

Butuh perangkat fisik dengan Bluetooth dan sensor BLE yang mendukung Heart Rate Service.

---

## 🧪 Testing

```bash
flutter analyze
flutter test
```
