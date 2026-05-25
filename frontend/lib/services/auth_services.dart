import 'dart:convert';
import 'package:frontend/services/api_client.dart';
import 'package:http/http.dart' as http;

class AuthService {
  //login
  static Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/auth/login'),
      headers: await ApiClient.headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      await ApiClient.saveToken(data['access_token']);
    } else {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'Login gagal');
    }
  }

  //register
  static Future<void> register(String username, String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/auth/register'),
      headers: await ApiClient.headers(),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'Register gagal');
    }
  }

  //logout
  static Future<void> logout() async {
    await ApiClient.clearToken();
  }
}