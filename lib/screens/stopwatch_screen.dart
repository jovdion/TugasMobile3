import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchScreen extends StatefulWidget {
  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  late Timer _timer;
  int _seconds = 0;
  bool _running = false;

  void _start() {
    if (_running) return;
    _running = true;
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  void _stop() {
    if (!_running) return;
    _timer.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer.cancel();
    setState(() {
      _running = false;
      _seconds = 0;
    });
  }

  @override
  void dispose() {
    if (_running) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _seconds ~/ 60;
    final secs = _seconds % 60;
    return Scaffold(
      appBar: AppBar(title: Text('Stopwatch')),
      body: Center(
        child: Text(
          '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
          style: TextStyle(fontSize: 48),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(onPressed: _start, child: Icon(Icons.play_arrow)),
          SizedBox(width: 10),
          FloatingActionButton(onPressed: _stop, child: Icon(Icons.pause)),
          SizedBox(width: 10),
          FloatingActionButton(onPressed: _reset, child: Icon(Icons.refresh)),
        ],
      ),
    );
  }
}
