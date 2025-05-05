import 'package:flutter/material.dart';
import 'dart:math';

class NumberTypeScreen extends StatefulWidget {
  const NumberTypeScreen({Key? key}) : super(key: key);

  @override
  _NumberTypeScreenState createState() => _NumberTypeScreenState();
}

class _NumberTypeScreenState extends State<NumberTypeScreen> {
  final _controller = TextEditingController();
  String _result = '';
  List<String> _numberTypes = [];
  bool _hasChecked = false;

  bool isPrime(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    
    for (var i = 5; i * i <= n; i += 6) {
      if (n % i == 0 || n % (i + 2) == 0) return false;
    }
    return true;
  }

  void _check() {
    final text = _controller.text;
    if (text.isEmpty) {
      setState(() {
        _result = 'Mohon masukkan angka';
        _numberTypes = [];
        _hasChecked = false;
      });
      return;
    }
    
    final num = double.tryParse(text);
    if (num == null) {
      setState(() {
        _result = 'Input bukan angka yang valid';
        _numberTypes = [];
        _hasChecked = false;
      });
      return;
    }
    
    final isInteger = num % 1 == 0;
    final intVal = num.toInt();
    List<String> types = [];
    
    // Determine number types
    if (isInteger) {
      types.add('Bilangan Bulat');
      
      if (intVal > 0) {
        types.add('Bilangan Positif');
        if (isPrime(intVal)) types.add('Bilangan Prima');
        types.add('Bilangan Asli');
      } else if (intVal == 0) {
        types.add('Bilangan Nol');
      } else {
        types.add('Bilangan Negatif');
      }
      
      if (intVal >= 0) types.add('Bilangan Cacah');
      if (intVal % 2 == 0) types.add('Bilangan Genap');
      else types.add('Bilangan Ganjil');
      
    } else {
      types.add('Bilangan Desimal');
      if (num > 0) types.add('Bilangan Positif');
      else if (num < 0) types.add('Bilangan Negatif');
    }
    
    setState(() {
      _result = 'Hasil Deteksi untuk $text:';
      _numberTypes = types;
      _hasChecked = true;
    });
  }

  // Mendapatkan warna untuk setiap jenis bilangan
  Color _getColorForNumberType(String type) {
    switch (type) {
      case 'Bilangan Bulat':
        return Colors.blue[700]!;
      case 'Bilangan Desimal':
        return Colors.purple[700]!;
      case 'Bilangan Positif':
        return Colors.green[700]!;
      case 'Bilangan Negatif':
        return Colors.red[700]!;
      case 'Bilangan Prima':
        return Colors.orange[700]!;
      case 'Bilangan Genap':
        return Colors.teal[700]!;
      case 'Bilangan Ganjil':
        return Colors.pink[700]!;
      case 'Bilangan Cacah':
        return Colors.indigo[700]!;
      case 'Bilangan Asli':
        return Colors.amber[800]!;
      case 'Bilangan Nol':
        return Colors.blueGrey[700]!;
      default:
        return Colors.blue[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          'Deteksi Jenis Bilangan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Input Area
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Input field
                      TextField(
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: 'Masukkan angka (contoh: 17, -42, 3.14)',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w300,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              setState(() {
                                _result = '';
                                _numberTypes = [];
                                _hasChecked = false;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Detection button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _check,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Deteksi',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Results section
                if (_hasChecked)
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    margin: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Result header
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            _controller.text,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        // Setiap jenis bilangan dalam kartu
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _numberTypes.length,
                          itemBuilder: (context, index) {
                            final type = _numberTypes[index];
                            final Color typeColor = _getColorForNumberType(type);
                            String explanation = '';
                            
                            switch (type) {
                              case 'Bilangan Bulat':
                                explanation = 'Bilangan tanpa komponen pecahan/desimal (contoh: -3, 0, 42)';
                                break;
                              case 'Bilangan Desimal':
                                explanation = 'Bilangan dengan komponen pecahan (contoh: 3.14, -2.5)';
                                break;
                              case 'Bilangan Positif':
                                explanation = 'Bilangan lebih besar dari nol (>0)';
                                break;
                              case 'Bilangan Negatif':
                                explanation = 'Bilangan lebih kecil dari nol (<0)';
                                break;
                              case 'Bilangan Prima':
                                explanation = 'Bilangan bulat positif yang hanya bisa dibagi habis oleh 1 dan dirinya sendiri';
                                break;
                              case 'Bilangan Genap':
                                explanation = 'Bilangan bulat yang habis dibagi 2';
                                break;
                              case 'Bilangan Ganjil':
                                explanation = 'Bilangan bulat yang tidak habis dibagi 2';
                                break;
                              case 'Bilangan Cacah':
                                explanation = 'Bilangan bulat dari 0 dan seterusnya (0, 1, 2, ...)';
                                break;
                              case 'Bilangan Asli':
                                explanation = 'Bilangan bulat positif mulai dari 1 (1, 2, 3, ...)';
                                break;
                              case 'Bilangan Nol':
                                explanation = 'Bilangan 0, bukan positif maupun negatif';
                                break;
                            }
                            
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      typeColor,
                                      typeColor.withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      type,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: Text(
                                        explanation,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    margin: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.numbers_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Masukkan angka dan tekan "Deteksi"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
