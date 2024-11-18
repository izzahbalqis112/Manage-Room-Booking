import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Assets/Colors.dart';
import '../managerModel.dart';
import 'login.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _staffIDController = TextEditingController();
  bool _isEmailValid = true;
  bool _isStaffIDValid = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _validateEmail(String email) {
    final RegExp googleEmail = RegExp(r'^[\w.+-]+@gmail\.com$', caseSensitive: false);
    final RegExp utemEmail = RegExp(r'^[\w.+-]+@(utem\.edu\.my|student\.utem\.edu\.my)$', caseSensitive: false);
    final RegExp outlookEmail = RegExp(r'^[\w.+-]+@outlook\.com$', caseSensitive: false);
    final RegExp yahooEmail = RegExp(r'^[\w.+-]+@yahoo\.com$', caseSensitive: false);

    if (googleEmail.hasMatch(email) ||
        utemEmail.hasMatch(email) ||
        outlookEmail.hasMatch(email) ||
        yahooEmail.hasMatch(email)) {
      return true;
    } else {
      return false; 
    }
  }

  bool _validateStaffID(String staffID) {
    if (staffID.isEmpty) {
      return false; 
    }

    final RegExp staffIDRegex = RegExp(r'^[a-zA-Z]+[0-9]+$');
    return staffIDRegex.hasMatch(staffID);
  }

  Future resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      Fluttertoast.showToast(
        msg: 'Password reset email sent. Check your inbox.',
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to send password reset email. Please try again later.',
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<ManagerModel> fetchManagerByEmail(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('managersAccount')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return ManagerModel.fromDocument(querySnapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>);
    } else {
      throw Exception('Manager not found for email: $email');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _staffIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.close, color: shadeColor5),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: false, 
      body: SingleChildScrollView( 
        child: Center(
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
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        "Enter appropriate info to Reset Password",
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
                                          color: _isEmailValid ? shadeColor1 : Colors.red,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _isEmailValid ? shadeColor1 : Colors.red,
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
                                    inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                                  ),
                                ),
                              ],
                            ),
                            if (!_isEmailValid)
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0, top: 5.0),
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
                                    controller: _staffIDController,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        borderSide: BorderSide(
                                          color: _isStaffIDValid ? shadeColor1 : Colors.red,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _isStaffIDValid ? shadeColor1 : Colors.red,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      hintText: "Staff ID",
                                      prefixIcon: Icon(Icons.person),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _isStaffIDValid = _validateStaffID(value);
                                      });
                                    },
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                                  ),
                                ),
                              ],
                            ),
                            if (!_isStaffIDValid)
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                                child: Text(
                                  'Incorrect staff id',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(height: 22), 
                                ElevatedButton(
                                  onPressed: resetPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: shadeColor1,
                                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 99.5), 
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(44), 
                                      side: BorderSide(color: shadeColor1, width: 2), 
                                    ),
                                    elevation: 5, 
                                  ),
                                  child: Text(
                                    "Reset Password",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white), 
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
      ),
    );
  }
}
