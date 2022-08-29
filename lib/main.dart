import 'package:flutter/material.dart';
import 'package:freebuddy/headphones/headphones_service/headphones_service_base.dart';
import 'package:freebuddy/headphones/headphones_service/headphones_service_bluetooth.dart';

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
  final service = HeadphonesServiceBluetooth();

  @override
  void initState() {
    service.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FreeBuddy")),
      body: Center(
        child: Column(
          children: [
            StreamBuilder(
              initialData: HeadphonesConnectionState.notPaired,
              stream: service.connectionState,
              builder:
                  (context, AsyncSnapshot<HeadphonesConnectionState> snapshot) {
                if (!snapshot.hasData) return const Text("no data!");
                switch (snapshot.data) {
                  case HeadphonesConnectionState.connected:
                    return const Text("connected");
                  case HeadphonesConnectionState.connecting:
                    return const Text("connecting");
                  case HeadphonesConnectionState.disconnected:
                    return const Text("disconnected");
                  case HeadphonesConnectionState.disconnecting:
                    return const Text("disconnecting");
                  case HeadphonesConnectionState.notPaired:
                    return const Text("notPaired");
                  default:
                    return const Text("unknown :(");
                }
              },
            ),
            TextButton(
              onPressed: () {
                service.init();
              },
              child: const Text("init"),
            ),
            TextButton(
              onPressed: () {
                service.dispose();
              },
              child: const Text("dispose"),
            ),
          ],
        ),
      ),
    );
  }
}
