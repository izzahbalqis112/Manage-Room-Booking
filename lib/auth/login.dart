import 'dart:convert';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:uuid/uuid.dart';
import '../Assets/Colors.dart';
import '../firstpage.dart';
import '../main/bottomnavbar/navbar.dart';
//import '../managerModel.dart';
import 'forgotpass.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailValid = true;
  bool _passwordVisible = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _validateEmail(String email) {
    // Regular expressions for the accepted email formats
    final RegExp googleEmail =
    RegExp(r'^[\w.+-]+@gmail\.com$', caseSensitive: false);
    final RegExp utemEmail =
    RegExp(r'^[\w.+-]+@(utem\.edu\.my|student\.utem\.edu\.my)$', caseSensitive: false);
    final RegExp outlookEmail =
    RegExp(r'^[\w.+-]+@outlook\.com$', caseSensitive: false);
    final RegExp yahooEmail =
    RegExp(r'^[\w.+-]+@yahoo\.com$', caseSensitive: false);

    // Check if the email matches any of the accepted formats
    if (googleEmail.hasMatch(email) ||
        utemEmail.hasMatch(email) ||
        outlookEmail.hasMatch(email) ||
        yahooEmail.hasMatch(email)) {
      return true; // Email is valid
    } else {
      return false; // Email is invalid
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  // Function to hash a password using SHA-256 algorithm
  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Encode the password to UTF-8
    var digest = sha256.convert(bytes); // Generate the SHA-256 hash
    return digest.toString(); // Return the hashed password as a string
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
      // Create ManagerModel object
      ManagerModel managerModel = ManagerModel(
        firstName: 'Admin',
        lastName: 'TF',
        email: _emailController.text,
        password: hashedPassword, // Hash the password
        managerID: managerID,
        picture: '',
        utemStaffID: '',
        role: '', // Assign converted UserRole
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
        'role': managerModel.role.toString().split('.').last, // Convert enum back to string for Firestore
      };

      // Save user data to Firestore with the user ID as the document ID
      await _firestore.collection('managersAccount').doc(managerModel.managerID).set(staffProfileData);
       */
      User? manager = managerCredential.user;

      // Fetch manager's email from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('managersAccount')
          .where('email', isEqualTo: _emailController.text)
          .get();

      // Check if manager email exists in the collection
      if (querySnapshot.docs.isNotEmpty) {
        String managerEmail = querySnapshot.docs.first.get('email');

        // Check if the logged-in user's email matches the manager's email
        if (manager?.email == _emailController.text && _emailController.text == managerEmail) {
          // Login successful, navigate to home screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ButtomNavBar()),
          );
        } else {
          // User is not authorized, show error message
          Fluttertoast.showToast(
            msg: 'You are not authorized to log in',
            gravity: ToastGravity.BOTTOM,
          );
        }
      } else {
        // Manager email not found in the collection
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
        false, // Set this to false to hide the back button
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
                    left: 40.0), // Adjust the left padding as needed
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                        height:
                        60), // Adjust the space between "Teaching Factory" and the new text
                    Text(
                      "Log in into your Account",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20), // Add space below the text
                    Container(
                      padding: EdgeInsets.only(left: 0.05), // Adjust the left padding for center-left alignment
                      width: MediaQuery.of(context).size.width - 80, // Adjust width as needed
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
                                            .red, // Dynamic border color based on email validity
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: _isEmailValid
                                            ? shadeColor1
                                            : Colors
                                            .red, // Dynamic border color based on email validity
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
                                  top: 5.0), // Adjust padding as needed
                              child: Text(
                                'Invalid email format',
                                style: TextStyle(
                                  color: Colors.red, // Adjust color as needed
                                  fontSize: 12, // Adjust font size as needed
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12), // Add space below the text
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
                                    shadeColor2, // You can adjust the color as needed
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(height: 5), // Ad
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: shadeColor1,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal:
                                      134), // Adjust padding for size
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        44),
                                    side: BorderSide(
                                        color: shadeColor1,
                                        width: 2), // Border color and width
                                  ),
                                  elevation: 5, //shadow
                                ),
                                onPressed: _login,
                                child: Text(
                                  "Log in",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white), // Text style
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
