import 'dart:convert';
import 'package:frontend/services/api_client.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('${ApiClient.baseUrl}/auth/profile'),
      headers: await ApiClient.headers(authorized: true),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Gagal ambil profil');
    }
  }
}