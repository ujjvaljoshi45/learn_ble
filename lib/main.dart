import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:learn_ble/controllers/ble_controller.dart';
import 'package:learn_ble/utils/tools.dart';
import 'package:permission_handler/permission_handler.dart';

//TODO: Readme
/*
check if bluetooth available ( press FAB )
then get permission
scan for device
get device result
do stuff
 */
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BLE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BleController bleController = BleController();
  @override
  void didChangeDependencies() async {
    await bleController.setLogging();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: _getCurrentState, child: const Text("Get State")),
            ElevatedButton(onPressed: _startScan, child: const Text('Start Scan')),
            ElevatedButton(onPressed: _printResults, child: const Text('Print')),
            ElevatedButton(onPressed: _connectToDevice, child: const Text('Connect')),
            ElevatedButton(onPressed: _getBondState, child: const Text('Get Bond State')),
            ElevatedButton(onPressed: _doStuff, child: const Text('Do Stuff')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPressed,
        tooltip: 'Increment',
        child: const Icon(Icons.bluetooth),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _onPressed() async {
    logEvent('Permission : ${(await Permission.bluetooth.serviceStatus).name}');
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothAdvertise.request();
    final check = await bleController.checkBluetooth();
    logEvent('My Res: $check');
    if (check) {
      await bleController.turnOn();
    }
  }
  _getCurrentState() {
    logEvent("State : ${bleController.getCurrentState()}");
  }
  _startScan() async {

    // Modify Scan parameters from the controller
    try {
      await bleController.startScan();
    } catch (e) {
      logEvent('Error : ${e.toString()}');
    }

    await bleController.getScanResults();
    // logEvent('response : ${response.runtimeType}');
    // await bleController.stopScan();
  }
  _printResults() {
    bleController.res = bleController.res.toSet().toList();

    logEvent('Len : ${bleController.res.length}');

    for (int i = 0; i < bleController.res.length; i++) {
      ScanResult sr = bleController.res[i];
      debugPrint(sr.toString());

    }
  }

  _connectToDevice()async  {
    try {
      await bleController.res.last.device.connect();
      await bleController.res.last.device.createBond();
    } catch(e) {
      logEvent("Error : $e");
    }
     logEvent("Con: ${bleController.res.last.device.isConnected}");
    logEvent("Bond: ${(await bleController.res.last.device.bondState.last).name}");
  }
  _getBondState()async {
    bleController.res.last.device.bondState.listen((event) {
      logEvent('Bond : ${event.name}');
    },);
  }

  _doStuff() async {
    // get services, then get characteristics, then apply read and write on the characteristics ( basically update this method as per your experiment)

    List<BluetoothService> list  =await bleController.res.last.device.discoverServices();
    logEvent('Len: ${list.length}');
    Map<String,List<BluetoothCharacteristic>> data = {};
    for (int i = 0 ; i < list.length; i++) {
      logEvent(list[i].toString());
      data.addAll({list[i].serviceUuid.str : list[i].characteristics});
    }
    logEvent('data: ${data.length}');
    List<BluetoothCharacteristic> readableChars = [];
    List<BluetoothCharacteristic> writeableChars = [];
    for (var json in data.keys) {
      debugPrint(json);
      for (var chars in data[json]!) {
        logEvent(chars.toString());
        if (chars.properties.read) readableChars.add(chars);
        if (chars.properties.write) writeableChars.add(chars);
      }
    }
    debugPrint('................................................');
    logEvent('readables : ${readableChars.length} ');
    for (int i = 0 ; i < readableChars.length; i++) {
      List<int> finalData = await readableChars[i].read();
      logEvent('FinalData : $finalData');
    }
    debugPrint('................................................');
    logEvent('writeables : ${writeableChars.length} ');
    for (int i = 0 ; i < writeableChars.length; i++) {
      try {
        await writeableChars[i].write([1,2,3],timeout: 20,);
        debugPrint("DONE!");
      } catch (e) {
        logEvent("ERROR: $e");
      }
    }
  }
  
}
