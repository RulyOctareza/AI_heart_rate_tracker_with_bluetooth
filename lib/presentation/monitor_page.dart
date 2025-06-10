import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../domain/heart_rate_model.dart';
import 'ble_monitor_bloc.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _autoScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BleMonitorBloc, BleState>(
      listener: (context, state) {
        if (state is UploadSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Upload success!')));
        }
        if (state is HeartRateUpdated) {
          _autoScrollToBottom();
        }
      },
      builder: (context, state) {
        List<HeartRateModel> data = [];
        if (state is HeartRateUpdated) {
          data = state.data;
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Monitor'),
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'History',
                onPressed: () => context.go('/history'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Reset Data',
                onPressed:
                    data.isEmpty
                        ? null
                        : () => context.read<BleMonitorBloc>().add(ResetData()),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Heart Rate Data:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child:
                      data.isEmpty
                          ? const Center(child: Text('No data yet'))
                          : ListView.builder(
                            controller: _scrollController,
                            itemCount: data.length,
                            itemBuilder: (context, i) {
                              final hr = data[i];
                              return ListTile(
                                leading: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                                title: Text('${hr.bpm} bpm'),
                                subtitle: Text(hr.timestamp.toIso8601String()),
                              );
                            },
                          ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed:
                        data.isEmpty
                            ? null
                            : () => context.read<BleMonitorBloc>().add(
                              UploadData(),
                            ),
                    child: const Text('Upload Data'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
