import 'package:flutter/material.dart';
import 'dart:math';

class NumberTypeScreen extends StatefulWidget {
  @override
  _NumberTypeScreenState createState() => _NumberTypeScreenState();
}

class _NumberTypeScreenState extends State<NumberTypeScreen> {
  final _controller = TextEditingController();
  String _result = '';

  bool isPrime(int n) {
    if (n < 2) return false;
    for (var i = 2; i <= sqrt(n); i++) if (n % i == 0) return false;
    return true;
  }

  void _check() {
    final text = _controller.text;
    if (text.isEmpty) return;
    final num = double.tryParse(text);
    if (num == null) {
      setState(() => _result = 'Input bukan angka');
      return;
    }
    final isInteger = num % 1 == 0;
    final intVal = num.toInt();
    List<String> types = [];
    if (isInteger) {
      types.add('Bulat');
      if (intVal >= 0) {
        types.add('Positif');
        if (isPrime(intVal)) types.add('Prima');
      } else types.add('Negatif');
      if (intVal >= 0) types.add('Cacah');
    } else {
      types.add('Desimal');
    }
    setState(() => _result = types.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deteksi Jenis Bilangan')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Masukkan angka'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _check, child: Text('Cek')),
            SizedBox(height: 20),
            Text(_result, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
