import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/heart_rate_model.dart';
import '../data/heart_rate_db.dart';

part 'ble_event.dart';
part 'ble_state.dart';

class BleMonitorBloc extends Bloc<BleEvent, BleState> {
  StreamSubscription? _scanSub;
  StreamSubscription? _notifySub;
  BluetoothDevice? _connectedDevice;
  final List<HeartRateModel> _data = [];

  static final heartRateServiceUuid = Guid(
    '0000180d-0000-1000-8000-00805f9b34fb',
  );
  static final heartRateCharUuid = Guid('00002a37-0000-1000-8000-00805f9b34fb');

  BleMonitorBloc() : super(InitialState()) {
    on<StartScan>((event, emit) async {
      emit(ScanningState());
      await _scanSub?.cancel();
      FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        add(DeviceFound(results));
      });
    });

    on<DeviceFound>((event, emit) {
      emit(DeviceListState(event.devices));
    });

    on<ConnectToDevice>((event, emit) async {
      emit(ConnectingState());
      try {
        await event.device.connect();
        _connectedDevice = event.device;
        emit(ConnectedState(event.device));
        // Discover services
        List<BluetoothService> services = await event.device.discoverServices();
        for (var service in services) {
          if (service.uuid == heartRateServiceUuid) {
            for (var c in service.characteristics) {
              if (c.uuid == heartRateCharUuid && c.properties.notify) {
                await c.setNotifyValue(true);
                _notifySub = c.onValueReceived.listen((value) {
                  if (value.isNotEmpty) {
                    int bpm = value.length > 1 ? value[1] : value[0];
                    _data.add(
                      HeartRateModel(bpm: bpm, timestamp: DateTime.now()),
                    );
                    add(HeartRateReceived(bpm));
                  }
                });
              }
            }
          }
        }
      } catch (e) {
        emit(ErrorState('Failed to connect: $e'));
      }
    });

    on<HeartRateReceived>((event, emit) async {
      // Simpan ke database setiap kali data baru diterima
      await HeartRateDb.insert(
        HeartRateModel(bpm: event.bpm, timestamp: DateTime.now()),
      );
      emit(HeartRateUpdated(List.from(_data)));
    });

    on<ResetData>((event, emit) async {
      _data.clear();
      await HeartRateDb.clearAll();
      emit(HeartRateUpdated(List.from(_data)));
    });

    on<UploadData>((event, emit) async {
      await Future.delayed(Duration(seconds: 1));
      emit(UploadSuccess());
    });
  }

  @override
  Future<void> close() {
    _scanSub?.cancel();
    _notifySub?.cancel();
    _connectedDevice?.disconnect();
    return super.close();
  }
}
