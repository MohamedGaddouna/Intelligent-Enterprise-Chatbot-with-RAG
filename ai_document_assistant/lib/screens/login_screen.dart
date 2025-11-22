import 'package:flutter/material.dart';
import 'chat_screen.dart';

class LoginScreen extends StatelessWidget {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  void _login(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => ChatScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _userCtrl, decoration: InputDecoration(labelText: 'Username')),
            TextField(controller: _passCtrl, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 12),
            ElevatedButton(onPressed: () => _login(context), child: Text('Login'))
          ],
        ),
      ),
    );
  }
}
