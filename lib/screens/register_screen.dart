import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String selectedRole = 'patient';

  void submitRegister()async{
    final authProvider=Provider.of<AuthProvider>(context,listen: false);

    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    bool success = await authProvider.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
      selectedRole,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful! Please login.')),
      );
      // Go back to Login Screen
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. Try a different email.')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    final customBorder = OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromRGBO(44, 162, 158, 1.0), width: 2.0)
    );
    final focusedBorder = OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2.5)
    );
    final customLabelStyle = TextStyle(color: Color.fromRGBO(44, 162, 158, 2.0));

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Image.asset('assets/images/meditrack.png', height: 120),
                ),
                SizedBox(height: 30),

                // Name Field
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: customLabelStyle,
                    enabledBorder: customBorder,
                    focusedBorder: focusedBorder,
                  ),
                ),
                SizedBox(height: 20),

                // Email Field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: customLabelStyle,
                    enabledBorder: customBorder,
                    focusedBorder: focusedBorder,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: customLabelStyle,
                    enabledBorder: customBorder,
                    focusedBorder: focusedBorder,
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),

                // Role Dropdown
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Select Role',
                    labelStyle: customLabelStyle,
                    enabledBorder: customBorder,
                    focusedBorder: focusedBorder,
                  ),
                  items: [
                    DropdownMenuItem(value: 'patient', child: Text('Patient',style: TextStyle(color: Color.fromRGBO(44, 162, 158, 1.0)),)),
                    DropdownMenuItem(value: 'doctor', child: Text('Doctor',style: TextStyle(color: Color.fromRGBO(44, 162, 158, 1.0)),)),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
                SizedBox(height: 30),

                // Register Button
                isLoading
                    ? CircularProgressIndicator()
                    : Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submitRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(44, 162, 158, 1.0),
                      foregroundColor: Colors.white,
                      elevation: 5,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Color.fromRGBO(44, 162, 158, 1.0)),
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
