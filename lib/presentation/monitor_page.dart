import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/heart_rate_model.dart';
import 'ble_monitor_bloc.dart';

class MonitorPage extends StatelessWidget {
  const MonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BleMonitorBloc, BleState>(
      listener: (context, state) {
        if (state is UploadSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Upload success!')));
        }
      },
      builder: (context, state) {
        List<HeartRateModel> data = [];
        if (state is HeartRateUpdated) {
          data = state.data;
        }
        return Scaffold(
          appBar: AppBar(title: Text('Monitor')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Heart Rate Data:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Expanded(
                  child:
                      data.isEmpty
                          ? Center(child: Text('No data yet'))
                          : ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, i) {
                              final hr = data[i];
                              return ListTile(
                                leading: Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                                title: Text('${hr.bpm} bpm'),
                                subtitle: Text(hr.timestamp.toIso8601String()),
                              );
                            },
                          ),
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed:
                        data.isEmpty
                            ? null
                            : () => context.read<BleMonitorBloc>().add(
                              UploadData(),
                            ),
                    child: Text('Upload Data'),
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
