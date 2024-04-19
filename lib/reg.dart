import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'User.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'constants.dart';

class Reg extends StatefulWidget {
  Reg({Key? key}) : super(key: key);

  @override
  _RegState createState() => _RegState();
}

class _RegState extends State<Reg> {
  String selectedCountry = 'Canada';

  final TextEditingController lastController = TextEditingController();
  final TextEditingController firstController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isObscured = true;
  bool _isConfirmPasswordObscured = true;
  Future<void> registerUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.baseUrl + '/api/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 204) {
        // Registration successful
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Registration failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register.Email is already in use !'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      // Handle API call errors
      print('API call failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to register. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
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
                  "Register",
                  style: TextStyle(fontSize: 22),
                ),
              ),
              SizedBox(height: 10.0),
              Center(
                child: Container(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Email", style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10.0),
                      TextFormField(
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
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      Text("First Name", style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: firstController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your first name",
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
                        ),
                      ),
                      Text("Last Name", style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: lastController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your last name",
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
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text("Password", style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10.0),
                      TextFormField(
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
                      SizedBox(height: 10.0),
                      Text("Confirm Password", style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: _isConfirmPasswordObscured,
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
                          hintText: "Confirm your password",
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
                              _isConfirmPasswordObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordObscured =
                                    !_isConfirmPasswordObscured;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: [
                          Text("Country", style: TextStyle(fontSize: 18)),
                          Expanded(
                            child: CountryListPick(
                                appBar: AppBar(
                                  title: Text('Pick your country'),
                                ),
                                theme: CountryTheme(
                                  isShowFlag: true,
                                  isShowTitle: false,
                                  isShowCode: false,
                                  isDownIcon: true,
                                  showEnglishName: true,
                                ),
                                initialSelection: '+1',
                                onChanged: (CountryCode? code) {
                                  selectedCountry = code?.name ?? '';
                                  print(selectedCountry);
                                },
                                useUiOverlay: false,
                                useSafeArea: true),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState?.validate() ?? false) {
                                // Create a User object with the entered information
                                User user = User(
                                  username: emailController.text,
                                  id: "0",
                                  email: emailController.text,
                                  firstName: firstController.text,
                                  lastName: lastController.text,
                                  password: passwordController.text,
                                  country: selectedCountry,
                                );

                                // Call the API with the user object
                                registerUser(user);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
