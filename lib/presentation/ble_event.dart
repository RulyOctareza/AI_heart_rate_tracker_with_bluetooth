part of 'ble_monitor_bloc.dart';

abstract class BleEvent {}

class StartScan extends BleEvent {}

class DeviceFound extends BleEvent {
  final List<ScanResult> devices;
  DeviceFound(this.devices);
}

class ConnectToDevice extends BleEvent {
  final BluetoothDevice device;
  ConnectToDevice(this.device);
}

class HeartRateReceived extends BleEvent {
  final int bpm;
  HeartRateReceived(this.bpm);
}

class UploadData extends BleEvent {}

class ResetData extends BleEvent {}
