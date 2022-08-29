import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'headphones/headphones_connection_cubit.dart';

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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<HeadphonesConnectionCubit>(
              create: (_) => HeadphonesConnectionCubit(
                  bluetooth: FlutterBluetoothSerial.instance)),
        ],
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FreeBuddy")),
      body: Center(
        child: Column(
          children: [
            BlocBuilder<HeadphonesConnectionCubit, HeadphonesObject>(
              builder: (context, state) {
                if (state is HeadphonesConnected) {
                  return const Text("connected");
                } else if (state is HeadphonesConnecting) {
                  return const Text("connecting");
                } else if (state is HeadphonesDisconnected) {
                  return const Text("disconnected");
                } else if (state is HeadphonesNotPaired) {
                  return const Text("notPaired");
                } else {
                  return const Text("unknown :(");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
