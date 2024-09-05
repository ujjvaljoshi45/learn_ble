import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:learn_ble/utils/tools.dart';

class BleController {
  List<ScanResult> res = [];
  Future<void> setLogging() async =>
      await FlutterBluePlus.setLogLevel(LogLevel.verbose, color: false);

  Future<bool> checkBluetooth() async => await FlutterBluePlus.isSupported.then(
        (value) async {
          if (value) {
            FlutterBluePlus.adapterState.listen(
              (event) {
                logEvent('Adapter : ${event.name}');
              },
            );
            await FlutterBluePlus.setOptions(
              showPowerAlert: true,
            );
          } else {
            logEvent('Bluetooth Un-Available!');
          }
          return value;
        },
      );

  turnOn() async => Platform.isAndroid
      ? await FlutterBluePlus.turnOn().whenComplete(
          () {
            logEvent('Turn On!');
          },
        )
      : null;

  Future startScan() async {
    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5), androidUsesFineLocation: true,
androidScanMode: AndroidScanMode.lowPower,

        // withServices: [Guid("180D")],   // Filter by service UUID (optional)
        // withNames: ["PHC_DEVICE"],    // PHC_DEVICE it the name of our Development Kit       // Filter by device name (optional)
      );
      logEvent('Scan Done');
    } catch (e) {
      logEvent('Scan Error : $e');
    }
  }

  getScanResults() async {
    FlutterBluePlus.onScanResults.listen((results) {
      logEvent('Printing...');
      logEvent(results.last.toString());
      if (results.isNotEmpty) {
        res = results;
      } else {
        logEvent('Empty');
      }
    }, onError: (e) => logEvent("Error $e"));
  }

  stopScan() async => await FlutterBluePlus.stopScan().whenComplete(
        () {
          logEvent('Stopped');
        },
      );
  getCurrentState() => FlutterBluePlus.adapterStateNow.name;
}
