import 'dart:convert';
import 'dart:html' as html; // For PDF upload on Web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SmartPDFChatApp());
}

class SmartPDFChatApp extends StatelessWidget {
  const SmartPDFChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Smart PDF Chat Assistant",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        fontFamily: "Roboto",
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  final String baseUrl = "http://127.0.0.1:8000";

  // ---------------------------------------------------------------
  // UPLOAD PDF
  // ---------------------------------------------------------------
  Future<void> uploadPDF() async {
    final html.InputElement uploadInput = html.InputElement(type: "file");
    uploadInput.accept = "application/pdf";
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final file = uploadInput.files?.first;
      if (file == null) return;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      final data = reader.result as List<int>;

      final request =
          http.MultipartRequest("POST", Uri.parse("$baseUrl/upload"));
      request.files.add(
        http.MultipartFile.fromBytes("file", data, filename: file.name),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(json["message"]),
          backgroundColor: Colors.blueAccent,
        ),
      );
    });
  }

  // ---------------------------------------------------------------
  // ASK A QUESTION
  // ---------------------------------------------------------------
  Future<void> askQuestion(String question) async {
    setState(() {
      messages.add({"sender": "user", "text": question});
      messages.add({"sender": "bot", "text": "Typing..."});
    });

    final response = await http.post(
      Uri.parse("$baseUrl/ask"),
      body: {"question": question},
    );

    final data = jsonDecode(response.body);

    setState(() {
      messages.removeLast(); // remove "Typing..."
      messages.add({"sender": "bot", "text": data["answer"]});
    });
  }

  // ---------------------------------------------------------------
  // CHAT BUBBLE
  // ---------------------------------------------------------------
  Widget buildMessage(Map<String, String> msg) {
    bool isUser = msg["sender"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        child: Text(
          msg["text"]!,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // UI BUILD
  // ---------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------- BACKGROUND GRADIENT ----------
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffdfe9f3), Color(0xffffffff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 900,
            margin: const EdgeInsets.all(30),
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))
              ],
            ),

            // ---------------- CHAT CONTAINER -----------------
            child: Column(
              children: [
                // ---------------- TOP BAR -----------------
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          size: 28, color: Colors.blueAccent),
                      const SizedBox(width: 10),
                      const Text(
                        "Smart PDF Chat Assistant",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: uploadPDF,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Upload PDF"),
                      ),
                    ],
                  ),
                ),

                // ---------------- CHAT MESSAGES -----------------
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: messages.map(buildMessage).toList(),
                  ),
                ),

                // ---------------- INPUT BAR -----------------
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: "Ask something based on your PDF...",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            askQuestion(controller.text.trim());
                            controller.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                        child: const Text("Send"),
                      )
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
}
