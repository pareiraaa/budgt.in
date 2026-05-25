import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:3000'; //android
  // static const String baseUrl = 'http://localhost:3000'; //web

  //token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> clearToken() async {                    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> headers({bool authorized = false}) async {
    final h = {'Content-Type': 'application/json'};
    if (authorized) {
      final token = await getToken();
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }
}