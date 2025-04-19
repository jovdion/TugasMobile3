import 'package:flutter/material.dart';

class TimeConvertScreen extends StatefulWidget {
  @override
  _TimeConvertScreenState createState() => _TimeConvertScreenState();
}

class _TimeConvertScreenState extends State<TimeConvertScreen> {
  final _controller = TextEditingController();
  String _output = '';

  void _convert() {
    final text = _controller.text;
    final years = double.tryParse(text);
    if (years == null) {
      setState(() => _output = 'Input tidak valid');
      return;
    }
    final days = years * 365;
    final hours = days * 24;
    final minutes = hours * 60;
    final seconds = minutes * 60;
    setState(() => _output =
        '${days.toStringAsFixed(2)} hari\n'
        '${hours.toStringAsFixed(2)} jam\n'
        '${minutes.toStringAsFixed(2)} menit\n'
        '${seconds.toStringAsFixed(2)} detik');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Konversi Waktu')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Tahun'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _convert, child: Text('Konversi')),
            SizedBox(height: 20),
            Text(_output, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}