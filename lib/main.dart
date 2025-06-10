import 'package:flutter/material.dart';
import 'presentation/scanner_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/ble_monitor_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BleMonitorBloc(),
      child: MaterialApp(title: 'BLE Monitor', home: ScannerPage()),
    );
  }
}
