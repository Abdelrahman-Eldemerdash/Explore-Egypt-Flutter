import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'home.dart';
import 'reg.dart';
import 'User.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_data.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 80, 0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.black),
                ),
                Spacer(),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/logo.png',
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Center(
            child: Text(
              "Login",
              style: TextStyle(fontSize: 22),
            ),
          ),
          SizedBox(height: 10.0),
          Center(
            child: Container(
              width: 280,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Email", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10.0),
                    Container(
                      child: TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }

                          final emailRegex =
                              RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your email",
                          hintStyle: TextStyle(
                              fontSize: 13, fontStyle: FontStyle.italic),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text("Password", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10.0),
                    Container(
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: _isObscured,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }

                          if (!value.contains(RegExp(r'[A-Z]'))) {
                            return 'Password should contain at least one\nuppercase letter';
                          }

                          if (!value
                              .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                            return 'Password missing at least one\nspecial character';
                          }

                          if (value.length < 8) {
                            return 'Password should be at \nleast 8 characters long';
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          hintStyle: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    GestureDetector(
                      onTap: () {
                        print("Forgot Password clicked");
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Add the functionality when the button is pressed
                              FocusScope.of(context).unfocus();
                              login(emailController.text,
                                  passwordController.text);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF176FF2), // Change button color here
                            padding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              color: Color(0xFF176FF2), // Change register text color here
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Reg()), // Replace LoginPage with your actual login page class
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> login(String email, String password) async {
    const String apiUrl = Constants.baseUrl + '/api/User/login';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the user data.
        var userData = json.decode(response.body);
        print('Login successful: $userData');
        User user = User.fromJson(userData);
        currentUser = user;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        // Handle different responses or show a generic error message
        print('Failed to login. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wrong email or password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Caught error: $e');
      // Handle network errors, timeouts, etc.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to login. Please check your internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
