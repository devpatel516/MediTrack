import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import 'register_screen.dart';
import 'doctor_dashboard.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController=TextEditingController();
  final passwordController=TextEditingController();

  void submitLogin() async{
    final authprovider=Provider.of<AuthProvider>(context,listen: false);
    bool success=await authprovider.login(emailController.text.trim(),passwordController.text.trim());

    if(success){
      if(authprovider.role=='doctor'){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DoctorDashboard())
        );
      }else{
        print('Navigate to Patient Dashbord');
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Check your credentials.')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: Center(
      child:SingleChildScrollView(
          child:Padding(padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Image.asset('assets/images/meditrack.png'),
          ),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color.fromRGBO(44, 162, 158, 2.0)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(
                      44, 162, 158, 1.0),width: 2.0)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue,width: 2.5)
                )),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 20,),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Color.fromRGBO(44, 162, 158, 2.0)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(
                      44, 162, 158, 1.0),width: 2.0)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:BorderSide(color: Colors.blue,width: 2.5)
                )
            ),
            obscureText: true,
          ),
          SizedBox(height: 30,),
          isLoading ? CircularProgressIndicator() : Container(
              width: double.infinity,
              child:ElevatedButton(
                  onPressed: submitLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(44, 162, 158, 1.0),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Login',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)
              ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            child: Text(
              "Don't have an account? Register here",
              style: TextStyle(color: Color.fromRGBO(44, 162, 158, 1.0)),
            ),
          )
        ],
      ),)),)
    );
  }
}
