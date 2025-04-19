import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_error != null) ...[
                Text(_error!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 12),
              ],
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                onSaved: (val) => _username = val ?? '',
                validator: (val) => val!.isEmpty ? 'Masukkan username' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (val) => _password = val ?? '',
                validator: (val) => val!.isEmpty ? 'Masukkan password' : null,
              ),
              SizedBox(height: 20),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _submit(context),
                      child: Text('Login'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await context.read<AuthProvider>().login(_username, _password);
    } catch (e) {
      setState(() => _error = 'Username atau password salah');
    } finally {
      setState(() => _loading = false);
    }
  }
}
