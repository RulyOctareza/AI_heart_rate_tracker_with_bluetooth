import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ble_monitor_bloc.dart';
import 'monitor_page.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BleMonitorBloc, BleState>(
      listener: (context, state) {
        if (state is ErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is ConnectedState) {
          // Hindari push berulang jika sudah di halaman MonitorPage
          if (ModalRoute.of(context)?.settings.name != '/monitor') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const MonitorPage(),
                settings: RouteSettings(name: '/monitor'),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is InitialState || state is ErrorState) {
          return Scaffold(
            appBar: AppBar(title: Text('BLE Scanner')),
            body: Center(
              child: ElevatedButton(
                onPressed:
                    () => context.read<BleMonitorBloc>().add(StartScan()),
                child: Text('Start Scan'),
              ),
            ),
          );
        } else if (state is ScanningState) {
          return Scaffold(
            appBar: AppBar(title: Text('BLE Scanner')),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is DeviceListState) {
          return Scaffold(
            appBar: AppBar(title: Text('BLE Scanner')),
            body: ListView.builder(
              itemCount: state.devices.length,
              itemBuilder: (context, i) {
                final r = state.devices[i];
                return ListTile(
                  title: Text(
                    r.device.advName.isEmpty ? '(unknown)' : r.device.advName,
                  ),
                  subtitle: Text(r.device.remoteId.str),
                  trailing: Text('${r.rssi}'),
                  onTap:
                      () => context.read<BleMonitorBloc>().add(
                        ConnectToDevice(r.device),
                      ),
                );
              },
            ),
          );
        } else if (state is ConnectingState) {
          return Scaffold(
            appBar: AppBar(title: Text('BLE Scanner')),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
