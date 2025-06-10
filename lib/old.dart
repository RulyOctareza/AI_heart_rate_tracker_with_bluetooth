// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:intl/intl.dart';
// import 'package:permission_handler/permission_handler.dart';

// // UUID Kunci untuk HID Service dan Report Characteristic
// final Guid SERVICE_UUID = Guid("00001812-0000-1000-8000-00805f9b34fb");
// final Guid CHARACTERISTIC_UUID = Guid("00002a4d-0000-1000-8000-00805f9b34fb");

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Bluetooth Shutter Controller',
//       theme: ThemeData(
//         primarySwatch: Colors.indigo,
//         useMaterial3: true,
//         scaffoldBackgroundColor: Colors.grey[50],
//         appBarTheme: AppBarTheme(
//           backgroundColor: Colors.indigo[400],
//           foregroundColor: Colors.white,
//         ),
//       ),
//       home: const BluetoothShutterScreen(),
//     );
//   }
// }

// class BluetoothShutterScreen extends StatefulWidget {
//   const BluetoothShutterScreen({super.key});

//   @override
//   State<BluetoothShutterScreen> createState() => _BluetoothShutterScreenState();
// }

// class _BluetoothShutterScreenState extends State<BluetoothShutterScreen>
//     with TickerProviderStateMixin {
//   // Variabel koneksi Bluetooth
//   BluetoothDevice? connectedDevice;
//   StreamSubscription? scanSubscription;
//   StreamSubscription? dataSubscription;

//   // Variabel status UI
//   bool isScanning = false;
//   bool isConnecting = false;
//   List<ScanResult> discoveredDevices = [];
//   String statusMessage = "Silakan mulai scan untuk mencari perangkat.";

//   // Variabel data dan analitik
//   int pressCount = 0;
//   DateTime? lastPressTime;
//   List<double> intervalHistory = [];

//   // Variabel untuk animasi
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initBluetooth();
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
//     );
//   }

//   @override
//   void dispose() {
//     scanSubscription?.cancel();
//     dataSubscription?.cancel();
//     _pulseController.dispose();
//     connectedDevice?.disconnect();
//     super.dispose();
//   }

//   Future<void> _initBluetooth() async {
//     await [
//       Permission.bluetooth,
//       Permission.bluetoothScan,
//       Permission.bluetoothConnect,
//     ].request();
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.redAccent : Colors.green,
//       ),
//     );
//   }

//   Future<void> _startScan() async {
//     if (isScanning) return;
//     setState(() {
//       isScanning = true;
//       discoveredDevices.clear();
//       statusMessage = "Mencari perangkat...";
//     });

//     try {
//       await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
//       scanSubscription = FlutterBluePlus.scanResults.listen(
//         (results) {
//           setState(() {
//             discoveredDevices = results;
//           });
//         },
//         onError: (e) {
//           _showSnackBar("Scan Error: $e", isError: true);
//         },
//       );
//       // Timer untuk menghentikan scan dan memberi pesan
//       Timer(const Duration(seconds: 15), () {
//         if (mounted && isScanning) {
//           setState(() {
//             isScanning = false;
//             statusMessage =
//                 discoveredDevices.isEmpty
//                     ? "Tidak ada perangkat ditemukan. Coba lagi."
//                     : "Pilih perangkat untuk terhubung.";
//           });
//         }
//       });
//     } catch (e) {
//       _showSnackBar("Gagal memulai scan: $e", isError: true);
//       setState(() => isScanning = false);
//     }
//   }

//   Future<void> _connectToDevice(BluetoothDevice device) async {
//     if (isConnecting) return;
//     setState(() {
//       isConnecting = true;
//       statusMessage = "Menghubungkan ke ${device.platformName}...";
//     });

//     // =======================================================================
//     // TAHAP 1: KONEKSI UNTUK BONDING
//     // =======================================================================
//     try {
//       print("🏁 STAGE 1: Connecting for Pairing...");
//       await device.connect(timeout: const Duration(seconds: 15));

//       print(
//         "✅ STAGE 1: Connection established. Requesting pairing (bonding)...",
//       );
//       await device.createBond(timeout: 150);

//       print(
//         "✅ STAGE 1: Bonding request sent. Disconnecting to refresh cache...",
//       );
//       await device.disconnect();
//       await Future.delayed(const Duration(seconds: 2)); // Jeda penting!
//     } catch (e) {
//       _showSnackBar("❌ Proses Pairing Gagal: $e", isError: true);
//       await device.disconnect(); // Pastikan disconnect jika gagal
//       setState(() => isConnecting = false);
//       return;
//     }

//     // =======================================================================
//     // TAHAP 2: KONEKSI ULANG KE PERANGKAT YANG SUDAH DI-BONDING
//     // =======================================================================
//     try {
//       print("🏁 STAGE 2: Reconnecting to bonded device...");
//       await device.connect(timeout: const Duration(seconds: 15));
//       print("✅ STAGE 2: Reconnected. Discovering services...");
//       List<BluetoothService> services = await device.discoverServices();

//       bool notificationSet = false;
//       for (var service in services) {
//         if (service.uuid == SERVICE_UUID) {
//           for (var char in service.characteristics) {
//             if (char.uuid == CHARACTERISTIC_UUID && char.properties.notify) {
//               try {
//                 await char.setNotifyValue(true);
//                 dataSubscription = char.onValueReceived.listen(_onDataReceived);
//                 notificationSet = true;
//                 print(
//                   "🎉 SUCCESS! Notifications enabled for characteristic ${char.uuid}.",
//                 );
//               } catch (e) {
//                 print(
//                   "⚠️ Could not enable notifications for a characteristic, but will continue: $e",
//                 );
//               }
//             }
//           }
//         }
//       }

//       if (notificationSet) {
//         setState(() {
//           connectedDevice = device;
//           isConnecting = false;
//         });
//         _showSnackBar("✅ Terhubung Sepenuhnya!");
//       } else {
//         _showSnackBar(
//           "❌ Gagal setup notifikasi setelah pairing.",
//           isError: true,
//         );
//         await device.disconnect();
//         setState(() => isConnecting = false);
//       }
//     } catch (e) {
//       _showSnackBar(
//         "❌ Gagal menyambung ulang setelah pairing: $e",
//         isError: true,
//       );
//       setState(() => isConnecting = false);
//     }
//   }

//   void _onDataReceived(List<int> data) {
//     final now = DateTime.now();
//     setState(() {
//       pressCount++;
//       if (lastPressTime != null) {
//         double interval =
//             now.difference(lastPressTime!).inMilliseconds / 1000.0;
//         intervalHistory.add(interval);
//         if (intervalHistory.length > 10) intervalHistory.removeAt(0);
//       }
//       lastPressTime = now;
//     });
//     _pulseController.forward(from: 0.0);
//   }

//   Future<void> _disconnect() async {
//     if (connectedDevice != null) {
//       await connectedDevice!.disconnect();
//       setState(() {
//         connectedDevice = null;
//         pressCount = 0;
//         intervalHistory.clear();
//         lastPressTime = null;
//         statusMessage = "Silakan mulai scan untuk mencari perangkat.";
//       });
//       _showSnackBar("Koneksi terputus.");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Shutter Controller'),
//         actions: [
//           if (connectedDevice != null)
//             IconButton(
//               icon: const Icon(Icons.bluetooth_disabled),
//               onPressed: _disconnect,
//             ),
//         ],
//       ),
//       body: Center(
//         child:
//             connectedDevice == null ? _buildScanSection() : _buildDataSection(),
//       ),
//     );
//   }

//   Widget _buildScanSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           ElevatedButton.icon(
//             onPressed: (isScanning || isConnecting) ? null : _startScan,
//             icon:
//                 (isScanning || isConnecting)
//                     ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                     : const Icon(Icons.bluetooth_searching),
//             label: Text(
//               isConnecting
//                   ? 'Menghubungkan...'
//                   : (isScanning ? 'Mencari...' : 'Scan Perangkat'),
//             ),
//             style: ElevatedButton.styleFrom(
//               minimumSize: const Size(double.infinity, 50),
//               textStyle: const TextStyle(fontSize: 16),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(statusMessage, style: const TextStyle(color: Colors.grey)),
//           const Divider(height: 32),
//           Expanded(
//             child: ListView.builder(
//               itemCount: discoveredDevices.length,
//               itemBuilder: (context, index) {
//                 final result = discoveredDevices[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 4),
//                   child: ListTile(
//                     leading: const Icon(Icons.bluetooth, color: Colors.blue),
//                     title: Text(
//                       result.device.platformName.isNotEmpty
//                           ? result.device.platformName
//                           : "Unknown Device",
//                     ),
//                     subtitle: Text(result.device.remoteId.toString()),
//                     trailing: Text('${result.rssi} dBm'),
//                     onTap: () => _connectToDevice(result.device),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDataSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           ScaleTransition(
//             scale: _pulseAnimation,
//             child: Card(
//               elevation: 8,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(100),
//               ),
//               child: SizedBox(
//                 width: 200,
//                 height: 200,
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.camera_alt,
//                         size: 48,
//                         color: Colors.indigo,
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         "$pressCount",
//                         style: const TextStyle(
//                           fontSize: 56,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const Text(
//                         "Presses",
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           _buildStatisticsCard(),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatisticsCard() {
//     final avgInterval =
//         intervalHistory.isEmpty
//             ? 0.0
//             : intervalHistory.reduce((a, b) => a + b) / intervalHistory.length;
//     final lastInterval = intervalHistory.isEmpty ? 0.0 : intervalHistory.last;

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const Text(
//               "Statistik Interval",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Column(
//                   children: [
//                     const Text("Rata-rata"),
//                     Text(
//                       "${avgInterval.toStringAsFixed(2)}s",
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.orange,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     const Text("Terakhir"),
//                     Text(
//                       "${lastInterval.toStringAsFixed(2)}s",
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.purple,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
