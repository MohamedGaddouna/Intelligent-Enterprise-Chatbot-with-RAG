import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'http://localhost:8000';

  static Future<bool> uploadFile(String fileName, List<int> bytes) async {
    var uri = Uri.parse('$baseUrl/upload');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));
    var streamed = await request.send();
    return streamed.statusCode == 200;
  }

  static Future<String?> ask(String question) async {
    final res = await http.post(
      Uri.parse('$baseUrl/ask'),
      body: {'question': question},
    );
    if (res.statusCode == 200) {
      final j = jsonDecode(res.body);
      return j['answer'];
    }
    return null;
  }
}
