import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'ble_monitor_bloc.dart';

class ScannerPage extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  const ScannerPage({super.key, this.onToggleTheme});

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
          context.go('/monitor');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('BLE Scanner'),
            actions: [
              IconButton(
                icon: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: onToggleTheme,
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => context.go('/history'),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, BleState state) {
    if (state is InitialState || state is ErrorState) {
      return Center(
        child: ElevatedButton(
          onPressed: () => context.read<BleMonitorBloc>().add(StartScan()),
          child: const Text('Start Scan'),
        ),
      );
    } else if (state is ScanningState) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is DeviceListState) {
      if (state.devices.isEmpty) {
        return const Center(child: Text('No devices found'));
      }
      return ListView.separated(
        itemCount: state.devices.length,
        separatorBuilder: (_, __) => Divider(height: 1),
        itemBuilder: (context, i) {
          final r = state.devices[i];
          return ListTile(
            leading: const Icon(Icons.bluetooth, color: Colors.blue),
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
      );
    } else if (state is ConnectingState) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox.shrink();
  }
}
