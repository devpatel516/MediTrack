import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService{
  static const String baseUrl='https://meditrack-api-gxb1.onrender.com/api';
  final storage=const FlutterSecureStorage();

  Future<bool> register(String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role, 
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to register: ${jsonDecode(response.body)['error']}');
    }
  }

  Future<Map<String,dynamic>> login(String email,String password)async{
    final response=await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({'email':email,'password':password})
    );

    if(response.statusCode==200){
      final data=jsonDecode(response.body);

      await storage.write(key: 'jwt_token', value: data['token']);
      await storage.write(key: 'user_role', value: data['role']);
      await storage.write(key: 'user_id', value: data['userId']);
      return data;
    }else{
      throw Exception('Failed to login: ${jsonDecode(response.body)['error']}');
    }
  }

  Future<bool> createVisit(Map<String, dynamic> visitData) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.post(
      Uri.parse('$baseUrl/visits/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(visitData),
    );

    return response.statusCode == 201;
  }

  Future<List<dynamic>> getPatientHistory(String patientId) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('$baseUrl/visits/history/$patientId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load history');
    }
  }

  Future<Map<String, dynamic>> aiService(String transcript) async{
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.post(
      Uri.parse('$baseUrl/visits/ai'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"transcript":transcript})
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Server Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<dynamic>> getDoctorVisits() async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('$baseUrl/visits/doctor-visits'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load doctor visits');
    }
  }

  Future<void> logout() async {
    await storage.deleteAll();
  }
}