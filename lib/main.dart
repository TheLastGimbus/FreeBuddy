import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:freebuddy/headphones/mbb.dart';
import 'package:freebuddy/headphones/otter_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeBuddy',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamSubscription _periodSS;
  BluetoothConnection? otterConn;

  @override
  void initState() {
    super.initState();
    _periodSS = Stream.periodic(const Duration(milliseconds: 1000), (_) async {
      final devs = await FlutterBluetoothSerial.instance.getBondedDevices();
      final otters = devs.where(
          (d) => (d.isConnected && Otter.btMacRegex.hasMatch(d.address)));
      if (otterConn == null && otters.length == 1) {
        final otter = otters.first;
        otterConn = await BluetoothConnection.toAddress(otter.address);
        setState(() {});
      }
    }).listen((_) {});
  }

  @override
  Widget build(BuildContext context) {
    Widget ancButton(IconData icon, List<int> bytes) {
      return Expanded(
        child: FittedBox(
          child: IconButton(
            onPressed: () {
              final data = Mbb.getPayload(43, 4, Uint8List.fromList(bytes));
              print('data: $data');
              otterConn?.output.add(data);
            },
            icon: Icon(icon),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("FreeBuddy")),
      body: Center(
        child: otterConn == null
            ? const Text("Not connected :(")
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // Noise cancellation settings:
                children: [
                  ancButton(Icons.hearing_disabled, [1, 2, 1]),
                  ancButton(Icons.highlight_off, [1, 2, 0]),
                  ancButton(Icons.hearing, [1, 2, 2]),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _periodSS.cancel();
    super.dispose();
  }
}
