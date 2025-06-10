part of 'ble_monitor_bloc.dart';

abstract class BleState {}

class InitialState extends BleState {}

class ScanningState extends BleState {}

class DeviceListState extends BleState {
  final List<ScanResult> devices;
  DeviceListState(this.devices);
}

class ConnectingState extends BleState {}

class ConnectedState extends BleState {
  final BluetoothDevice device;
  ConnectedState(this.device);
}

class HeartRateUpdated extends BleState {
  final List<HeartRateModel> data;
  HeartRateUpdated(this.data);
}

class UploadSuccess extends BleState {}

class ErrorState extends BleState {
  final String message;
  ErrorState(this.message);
}
