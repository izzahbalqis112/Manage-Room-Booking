import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../Assets/Colors.dart';
import '../../managerModel.dart';

class AddNewStaffPage extends StatefulWidget {
  @override
  _AddNewStaffPageState createState() => _AddNewStaffPageState();
}

class _AddNewStaffPageState extends State<AddNewStaffPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _utemStaffIDController = TextEditingController();
  bool _isFirstNameValid = true;
  bool _isUtemStaffIDValid = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _passwordVisible = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedRole;
  File? _selectedImage;
  bool _isUploading = false;
  String? _photoUrl;
  String managerID = Uuid().v4(); // Generate managerID

  @override
  void initState() {
    super.initState();
  }

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

  bool _validatePassword(String password) {
    // Check if password length is at least 6 characters
    if (password.length < 6) {
      return false;
    }

    // Check for at least one uppercase letter
    bool hasUpperCase = false;
    // Count the number of uppercase letters
    int upperCaseCount = 0;
    for (int i = 0; i < password.length; i++) {
      if (password[i] == password[i].toUpperCase() && password[i] != password[i].toLowerCase()) {
        hasUpperCase = true;
        upperCaseCount++;
      }
    }

    // Check for at least one lowercase letter
    bool hasLowerCase = false;
    // Count the number of lowercase letters
    int lowerCaseCount = 0;
    for (int i = 0; i < password.length; i++) {
      if (password[i] == password[i].toLowerCase() && password[i] != password[i].toUpperCase()) {
        hasLowerCase = true;
        lowerCaseCount++;
      }
    }

    // Check for at least one special character
    bool hasSpecialChar = false;
    String specialChars = r'^ !@#$%^&*()_+{}|:<>?-=[]\;\';
    for (int i = 0; i < password.length; i++) {
      if (specialChars.contains(password[i])) {
        hasSpecialChar = true;
        break;
      }
    }

    // Return true only if all conditions are met
    // And if the desired count of uppercase and lowercase letters is achieved
    return hasUpperCase && hasLowerCase && hasSpecialChar && upperCaseCount >= 1 && lowerCaseCount >= 1;
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Encode the password to UTF-8
    var digest = sha256.convert(bytes); // Generate the SHA-256 hash
    return digest.toString(); // Return the hashed password as a string
  }

  bool _validateFirstName(String value) {
    return value.isNotEmpty;
  }

  bool _validateUtemStaffID(String value) {
    // Check if the value is empty
    if (value.isEmpty) {
      return false;
    }

    // Check if the value contains at least one lowercase letter
    bool hasLowerCase = false;
    for (int i = 0; i < value.length; i++) {
      if (value[i] == value[i].toLowerCase() && value[i] != value[i].toUpperCase()) {
        hasLowerCase = true;
        break;
      }
    }

    // Check if the value contains at least one digit (number)
    bool hasNumber = false;
    for (int i = 0; i < value.length; i++) {
      if (value.codeUnitAt(i) >= 48 && value.codeUnitAt(i) <= 57) {
        hasNumber = true;
        break;
      }
    }

    // Return true only if both conditions are met
    return hasLowerCase && hasNumber;
  }

  void _updateSelectedRole(String? role) {
    setState(() {
      _selectedRole = role ?? '';
    });
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    );
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }


  Future<String> _uploadUserProfilePhoto() async {
    if (managerID.isEmpty || _selectedImage == null) {
      throw Exception("Manager ID is empty or image not selected");
    }

    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('managerProfilePhotos') // The directory name in Firebase Storage
        .child(managerID) // Use managerID as the directory name
        .child('$managerID.jpg'); // The image file name

    final UploadTask uploadTask = storageRef.putFile(_selectedImage!);

    setState(() {
      _isUploading = true;
    });

    final TaskSnapshot uploadSnapshot = await uploadTask.whenComplete(() {});
    final String downloadUrl = await uploadSnapshot.ref.getDownloadURL();

    setState(() {
      _isUploading = false;
      _photoUrl = downloadUrl; // Update _photoUrl with the download URL
    });

    return downloadUrl;
  }


  Future<void> _saveUserDetails() async {
    try {

      String managerID = Uuid().v4();

      await _uploadUserProfilePhoto();

      String hashedPassword = hashPassword(_passwordController.text);

      // Create ManagerModel object
      ManagerModel managerModel = ManagerModel(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        password: hashedPassword, // Hash the password
        managerID: managerID, // Use the user ID as the managerID
        picture: _photoUrl,
        utemStaffID: _utemStaffIDController.text,
        role: _selectedRole ?? '', // Assign converted UserRole
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

      // Determine collection name based on role
      String collectionName = '';
      if (managerModel.role == 'Manager') {
        collectionName = 'managersAccount';
      } else if (managerModel.role == 'Staff') {
        collectionName = 'staffAccount';
      } // Add more conditions for other roles if needed

      // Save user data to Firestore with the determined collection name
      await _firestore.collection(collectionName).doc(managerModel.managerID).set(staffProfileData);

      // Navigate back
      Navigator.pop(context, true);
    } catch (e) {
      // Handle any errors that occur during user account creation or Firestore data saving
      print('Error creating user account or saving data to Firestore: $e');
      Fluttertoast.showToast(
        msg: 'Error: $e',
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _utemStaffIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close, color: shadeColor2),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Add New Staff',
                              style: TextStyle(fontSize: 22, color: shadeColor2, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: shadeColor2,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    44),
                                side: BorderSide(
                                    color: shadeColor2,
                                    width: 2), // Border color and width
                              ),
                            ),
                            onPressed: _saveUserDetails,
                            child: Text('Save',style: TextStyle(
                                color: Colors.white
                            ),),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: shadeColor3,
                            border: Border.all(
                              color: shadeColor2,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 26,
                                left: 35,
                                child: Container(
                                  padding: EdgeInsets.only(left: 0.05),
                                  width: MediaQuery.of(context).size.width - 80,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        alignment: Alignment.topCenter,
                                        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.22 - 185),
                                        child: Column(
                                          children: [
                                            _profileImage(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      TextField(
                                        controller: _emailController,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(32),
                                            borderSide: BorderSide(
                                              color: _isEmailValid ? shadeColor2 : Colors.red,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: _isEmailValid ? shadeColor2 : Colors.red,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          hintText: "Email",
                                          hintStyle: TextStyle(color: Colors.grey),
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
                                      SizedBox(height: 14),
                                      TextField(
                                        controller: _passwordController,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(32),
                                            borderSide: BorderSide(
                                              color: _isPasswordValid ? shadeColor2 : Colors.red,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: _isPasswordValid ? shadeColor2 : Colors.red,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          hintText: "Password",
                                          hintStyle: TextStyle(color: Colors.grey),
                                          prefixIcon: Icon(Icons.lock),
                                          fillColor: Colors.white,
                                          filled: true,
                                          suffixIcon: GestureDetector(
                                            onTap: _togglePasswordVisibility,
                                            child: Icon(
                                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                            ),
                                          ),
                                        ),
                                        obscureText: !_passwordVisible,
                                        onChanged: (value) {
                                          setState(() {
                                            _isPasswordValid = _validatePassword(value);
                                          });
                                        },
                                        keyboardType: TextInputType.visiblePassword,
                                        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                                      ),
                                      if (!_isPasswordValid)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                                          child: Text(
                                            'Password must be at least 6 characters with 1 uppercase, 1 lowercase, and 1 special character.',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      SizedBox(height: 14),
                                      TextField(
                                        controller: _firstNameController,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(32),
                                            borderSide: BorderSide(
                                              color: _isFirstNameValid ? shadeColor2 : Colors.red,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: _isFirstNameValid ? shadeColor2 : Colors.red,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          hintText: "First name",
                                          hintStyle: TextStyle(color: Colors.grey),
                                          prefixIcon: Icon(Icons.person),
                                          fillColor: Colors.white,
                                          filled: true,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _isFirstNameValid = _validateFirstName(value);
                                          });
                                        },
                                        keyboardType: TextInputType.text,
                                        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                                      ),
                                      if (!_isFirstNameValid)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                                          child: Text(
                                            'First name cannot be empty',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      SizedBox(height: 14),
                                      TextField(
                                        controller: _lastNameController,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(32),
                                            borderSide: BorderSide(
                                              color: shadeColor2,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: shadeColor2,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          hintText: "Last name (optional)",
                                          hintStyle: TextStyle(color: Colors.grey),
                                          prefixIcon: Icon(Icons.person),
                                          fillColor: Colors.white,
                                          filled: true,
                                        ),
                                        onChanged: (value) {
                                          // No validation needed for last name
                                        },
                                        keyboardType: TextInputType.text,
                                        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                                      ),
                                      SizedBox(height: 14),
                                      TextField(
                                        controller: _utemStaffIDController,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(32),
                                            borderSide: BorderSide(
                                              color: _isUtemStaffIDValid ? shadeColor2 : Colors.red,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: _isUtemStaffIDValid ? shadeColor2 : Colors.red,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          hintText: "Staff ID",
                                          hintStyle: TextStyle(color: Colors.grey),
                                          prefixIcon: Icon(Icons.business),
                                          fillColor: Colors.white,
                                          filled: true,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _isUtemStaffIDValid = _validateUtemStaffID(value);
                                          });
                                        },
                                        keyboardType: TextInputType.text,
                                        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                                      ),
                                      if (!_isUtemStaffIDValid)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                                          child: Text(
                                            'Utem Staff ID cant be empty',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      SizedBox(height: 14),
                                      _buildRoleSelection(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Implement round tick buttons for selecting the role
  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.only(left: 32),
              child: Text('Role : ',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            SizedBox(width: 5),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            SizedBox(width: 100),
            GestureDetector(
              onTap: () => _updateSelectedRole('Manager'),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black),
                  color: _selectedRole == 'Manager' ? shadeColor2 : Colors.transparent,
                ),
                child: _selectedRole == 'Manager'
                    ? Icon(Icons.check, size: 18, color: Colors.white)
                    : SizedBox(), // Show check icon if role is selected
              ),
            ),
            SizedBox(width: 10),
            Text('Manager'),
            SizedBox(width: 40),
            GestureDetector(
              onTap: () => _updateSelectedRole('Staff'),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black),
                  color: _selectedRole == 'Staff' ? shadeColor2 : Colors.transparent,
                ),
                child: _selectedRole == 'Staff'
                    ? Icon(Icons.check, size: 18, color: Colors.white)
                    : SizedBox(), // Show check icon if role is selected
              ),
            ),
            SizedBox(width: 10),
            Text('Staff'),
          ],
        ),
      ],
    );
  }

  Widget _profileImage() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Center(
            child: GestureDetector(
              onTap: () {
                _selectImage();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200.0,
                    height: 200.0,
                    child: (_selectedImage == null && (_photoUrl == null || _photoUrl!.isEmpty))
                        ? Material(
                      child: Image.asset(
                        'lib/assets/img/user.jpeg',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      clipBehavior: Clip.hardEdge,
                    )
                        : Material(
                      child: _selectedImage != null
                          ? Image.file(
                        _selectedImage!,
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      )
                          : CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                          width: 200.0,
                          height: 200.0,
                          padding: EdgeInsets.all(20),
                        ),
                        imageUrl: _photoUrl!,
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                  ),
                  if (_isUploading)
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}