import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Assets/Colors.dart';
import '../firstpage.dart';
import '../main/bottomnavbar/navbar.dart';
import 'forgotpass.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailValid = true;
  bool _passwordVisible = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _validateEmail(String email) {
    final RegExp googleEmail =
    RegExp(r'^[\w.+-]+@gmail\.com$', caseSensitive: false);
    final RegExp utemEmail =
    RegExp(r'^[\w.+-]+@(utem\.edu\.my|student\.utem\.edu\.my)$', caseSensitive: false);
    final RegExp outlookEmail =
    RegExp(r'^[\w.+-]+@outlook\.com$', caseSensitive: false);
    final RegExp yahooEmail =
    RegExp(r'^[\w.+-]+@yahoo\.com$', caseSensitive: false);

    if (googleEmail.hasMatch(email) ||
        utemEmail.hasMatch(email) ||
        outlookEmail.hasMatch(email) ||
        yahooEmail.hasMatch(email)) {
      return true; 
    } else {
      return false; 
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password); 
    var digest = sha256.convert(bytes); 
    return digest.toString(); 
  }

  void _login() async {
    try {
      UserCredential managerCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      /*
      String hashedPassword = hashPassword(_passwordController.text);
      String managerID = Uuid().v4();
      ManagerModel managerModel = ManagerModel(
        firstName: 'Admin',
        lastName: 'TF',
        email: _emailController.text,
        password: hashedPassword, 
        managerID: managerID,
        picture: '',
        utemStaffID: '',
        role: '', 
      );
      // Define user profile data
      Map<String, dynamic> staffProfileData = {
        'firstName': managerModel.firstName,
        'lastName': managerModel.lastName,
        'email': managerModel.email,
        'password': managerModel.password,
        'managerID': managerModel.managerID,
        'picture': managerModel.picture,
        'utemStaffID': managerModel.utemStaffID,
        'role': managerModel.role.toString().split('.').last, 
      };

      await _firestore.collection('managersAccount').doc(managerModel.managerID).set(staffProfileData);
       */
      User? manager = managerCredential.user;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('managersAccount')
          .where('email', isEqualTo: _emailController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String managerEmail = querySnapshot.docs.first.get('email');

        if (manager?.email == _emailController.text && _emailController.text == managerEmail) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ButtomNavBar()),
          );
        } else {
          Fluttertoast.showToast(
            msg: 'You are not authorized to log in',
            gravity: ToastGravity.BOTTOM,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'You are not authorized to log in',
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Login failed',
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
        false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: shadeColor5),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FirstPage()),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              'lib/assets/img/TF-logo1.png',
              width: 100,
              height: 100,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 40.0), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                        height:
                        60), 
                    Text(
                      "Log in into your Account",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.only(left: 0.05),
                      width: MediaQuery.of(context).size.width - 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32),
                                      borderSide: BorderSide(
                                        color: _isEmailValid
                                            ? shadeColor1
                                            : Colors
                                            .red, 
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: _isEmailValid
                                            ? shadeColor1
                                            : Colors
                                            .red,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    hintText: "Email",
                                    prefixIcon: Icon(Icons.email),
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _isEmailValid = _validateEmail(value);
                                    });
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .singleLineFormatter
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (!_isEmailValid)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0,
                                  top: 5.0),
                              child: Text(
                                'Invalid email format',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.only(left: 0.05),
                      width: MediaQuery.of(context).size.width - 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32),
                                      borderSide: BorderSide(
                                        color: shadeColor1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: shadeColor1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    hintText: "Password",
                                    prefixIcon: Icon(Icons.lock),
                                    fillColor: Colors.white,
                                    filled: true,
                                    suffixIcon: GestureDetector(
                                      onTap: _togglePasswordVisibility,
                                      child: Icon(
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                    ),
                                  ),
                                  obscureText: !_passwordVisible,
                                  keyboardType: TextInputType.visiblePassword,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .singleLineFormatter
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ForgotPassword(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color:
                                    shadeColor2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(height: 5),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: shadeColor1,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal:
                                      134), 
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        44),
                                    side: BorderSide(
                                        color: shadeColor1,
                                        width: 2), 
                                  ),
                                  elevation: 5, 
                                ),
                                onPressed: _login,
                                child: Text(
                                  "Log in",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
