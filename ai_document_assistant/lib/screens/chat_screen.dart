import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  void _pickAndUpload() async {
    var res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (res != null && res.files.single.bytes != null) {
      final ok = await ApiService.uploadFile(res.files.single.name, res.files.single.bytes!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Uploaded' : 'Upload failed')));
    }
  }

  void _sendQuestion() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() { messages.add({'who': 'me', 'text': q}); _controller.clear(); });
    final ans = await ApiService.ask(q);
    setState(() { messages.add({'who': 'bot', 'text': ans ?? 'No answer'}); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Document Assistant'), actions: [IconButton(icon: Icon(Icons.upload_file), onPressed: _pickAndUpload)]),
      body: Column(children: [
        Expanded(child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (_, i) {
            final m = messages[i];
            final align = m['who'] == 'me' ? CrossAxisAlignment.end : CrossAxisAlignment.start;
            return Container(padding: EdgeInsets.all(8), child: Column(crossAxisAlignment: align, children: [Text(m['text'] ?? '')]));
          },
        )),
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(children: [
            Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: 'Ask a question'))),
            IconButton(icon: Icon(Icons.send), onPressed: _sendQuestion)
          ]),
        )
      ]),
    );
  }
}
