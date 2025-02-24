// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String serverUrl = 'http://127.0.0.1:8000';
  fetchData() async {
    final res = await http.get(Uri.parse(serverUrl));
    if(res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}