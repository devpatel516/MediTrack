import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier{
  final ApiService apiService = ApiService();
  String? token;
  String? role;
  String? userId;
  bool isLoading=false;
  bool isAuthenticated=false;

  Future<bool> register(String name, String email, String password, String role)async{
    isLoading=true;
    notifyListeners();
    try{
      final success=await apiService.register(name, email, password, role);
      isLoading=false;
      notifyListeners();
      return success;
    }catch(e){
      isLoading=false;
      notifyListeners();
      print('Registration Error:$e');
      return false;
    }
  }

  Future<bool> login(String email,String password)async{
    isLoading=true;
    notifyListeners();
    try{
      final data=await apiService.login(email, password);
      token=data['token'];
      role = data['role'];
      userId = data['userId'];
      isLoading = false;
      notifyListeners();
      return true;
    }catch(e){
      isLoading=false;
      notifyListeners();
      print('Login Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await apiService.logout();
    token = null;
    role = null;
    userId = null;
    notifyListeners();
  }
}

