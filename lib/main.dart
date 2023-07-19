import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int heavyLoad(int iteration) {
    int value = 0;

    for (int i = 0; i < iteration; i++) value = i++;

    print(value);
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: MyHomePage(title: 'Multi-threading'),
    );
  }
}

/////isolation run code using multithread
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: CircularProgressIndicator(),
            ),
            ElevatedButton(
                onPressed: () {
                  heavyLoad(4000000000);
                },
                child: const Text("Start Heavy Process without Isolate")),
            ElevatedButton(
                onPressed: () {
                  try {
                    // onPressed();
                   print( compute(getComputeData, 1000));
                  } catch (e) {
                    print('error ------$e');
                  }
                },
                child: const Text("Start Heavy Process with isolate"))
          ],
        ),
      ),
    );
  }
}

///compute
int getComputeData(value) {
  int _count = 0;
  for (int i = 0; i < value; i++) {
    _count++;
    print('counter $_count');
  }
  return _count;
}

/// spawn
void onPressed() async {
  var receivePort = ReceivePort();
  await Isolate.spawn(gotoNext, [receivePort.sendPort, 4000000000]);
  final msg = await receivePort.first;
  print(msg);
}

void gotoNext(List<dynamic> args) {
  SendPort sendPort = args[0];
  log(args.toString());
  int _count = 0;
  for (int i = 0; i < args[1]; i++) {
    _count++;
    if ((_count % 100) == 0) {
      // print("isolate: " + _count.toString());
    }
  }
  Isolate.exit(sendPort, "OK :$_count");
}


int heavyLoad(int iteration) {
  int value = 0;

  for (int i = 0; i < iteration; i++) {
    value = i++;
  }

  print(value);
  return value;
}
