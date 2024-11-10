import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfrb_managerside/firstpage.dart';
import '../../Assets/Colors.dart';
import '../../auth/login.dart';
import 'editPicture.dart';
import 'editProfilePage.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _currentUser;
  Map<String, dynamic>? _userProfileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }


  Future<void> _getCurrentUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUser = currentUser;
      });
      await fetchAndDisplayUserData(_currentUser.email!);
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FirstPage()),
    );
  }

  Future<void> fetchAndDisplayUserData(String email) async {
    try {
      QuerySnapshot userDataSnapshot = await _firestore
          .collection('managersAccount')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userDataSnapshot.docs.isNotEmpty) {
        // Retrieve user data
        Map<String, dynamic> userData = (userDataSnapshot.docs.first.data() as Map<String, dynamic>);
        setState(() {
          _userProfileData = userData;
          _isLoading = false;
        });
      } else {
        print('User data does not exist.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _handleDeletePressed() async {
    try {
      // Get the user's email
      String? userEmail = _currentUser.email;

      // Query the user document based on the email
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('managersAccount')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      // Check if the user document exists
      if (userQuerySnapshot.docs.isNotEmpty) {
        // Get the user document reference
        DocumentReference userDocRef = userQuerySnapshot.docs.first.reference;

        // Delete the user document
        await userDocRef.delete();

        // Delete the user's account
        await _currentUser.delete();

        // Sign out the user after deletion
        await _auth.signOut();

        // Navigate to the login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        // User document does not exist
        print('User document not found.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account. User not found.'),
          ),
        );
      }
    } catch (e) {
      print('Error deleting user account: $e');

      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete account. Please try again later.'),
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete your account?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                // Perform the delete operation
                _handleDeletePressed();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _isLoading ? _buildLoadingScreen() : _buildProfileScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: CircularProgressIndicator(), // Display a circular progress indicator while loading
    );
  }

  Widget _buildProfileScreen() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: BoxDecoration(
                color: shadeColor2,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60.0),
                  bottomRight: Radius.circular(60.0),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 30.0,
          right: 10.0,
          child: IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.22 - 100,
          left: MediaQuery.of(context).size.width * 0.5 - 100,
          child: Column(
            children: [
              _profileImage(),
              _userDataView(),
            ],
          ),
        ),
        SizedBox(height: 20),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.22 - 100+ 220 + 86, // Adjust the top position accordingly
          left: MediaQuery.of(context).size.width * 0.06, // Adjust the left position accordingly
          child: Container(
            width: MediaQuery.of(context).size.width * 0.89,
            height: MediaQuery.of(context).size.height * 0.15,
            padding: EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: shadeColor2.withOpacity(0.5), // Set the border color here
                width: 2, // Set the border width as needed
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 0.05), // Adjust the left padding as needed
              child: Column(
                children: [
                  _userDataView1(),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.22 - 100 + 220 + 100 + MediaQuery.of(context).size.height * 0.15 + 20, // Adjust the top position accordingly
          left: MediaQuery.of(context).size.width * 0.126, // Adjust the left position accordingly
          child: Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: shadeColor2,
                  elevation: 5,
                  padding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 40
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        44),
                    side: BorderSide(
                        color: shadeColor2,
                        width: 2), // Border color and width
                  ),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(managerID: _currentUser.uid),
                    ),
                  );
                  if (result == true) {
                    // Refresh the user profile data
                    await fetchAndDisplayUserData(_currentUser.email!);
                  }
                },
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
              SizedBox(width: 10), // Add some space between buttons
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 30
                  ),
                  backgroundColor: Colors.red,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        44),
                    side: BorderSide(
                        color: Colors.red,
                        width: 2), // Border color and width
                  ),
                ),
                onPressed: () {
                  _showDeleteConfirmationDialog();
                },
                child: Text(
                  'Delete Account',
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _profileImage() {
    String? photoUrl = _userProfileData?['picture'];
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
          child: Stack(
            children: [
              Container(
                width: 200.0,
                height: 200.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl) // Use the updated image URL
                        : AssetImage('lib/assets/img/user.jpeg') as ImageProvider,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: shadeColor2,
                  ),
                  padding: EdgeInsets.all(4.0),
                  child: IconButton(
                    icon: Icon(Icons.edit,color: Colors.white,),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditPicture()),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            _userProfileData?['picture'] = value; // Update _userProfileData with the new photo URL
                          });
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _userDataView() {
    if (_userProfileData != null) {
      String firstName = _userProfileData!['firstName'] ?? '';
      String lastName = _userProfileData!['lastName'] ?? '';
      String role = _userProfileData!['role'] ?? '';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20.0),
          Text(
            '$firstName $lastName',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5.0),
          Text(
            '$role',
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _userDataView1() {
    if (_userProfileData != null) {
      String email = _userProfileData!['email'] ?? '';
      String utemStaffID = _userProfileData!['utemStaffID'] ?? '';

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 10.0), // Add some initial space
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Align text to the left
                  children: [
                    Icon(Icons.email, size: 20.0, color: Colors.black), // Email icon
                    SizedBox(width: 5.0),
                    Text(
                      'Email : ',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      email,
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Align text to the left
                  children: [
                    Icon(Icons.phone, size: 20.0, color: Colors.black), // Phone icon
                    SizedBox(width: 5.0),
                    Text(
                      'UTeM Staff ID  : ',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      utemStaffID,
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 10.0), // Add some final space
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}