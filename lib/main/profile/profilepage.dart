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
      String? userEmail = _currentUser.email;
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('managersAccount')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentReference userDocRef = userQuerySnapshot.docs.first.reference;
        await userDocRef.delete();
        await _currentUser.delete();
        await _auth.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        print('User document not found.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account. User not found.'),
          ),
        );
      }
    } catch (e) {
      print('Error deleting user account: $e');
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
                Navigator.of(context).pop(); 
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                _handleDeletePressed();
                Navigator.of(context).pop(); 
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
      child: CircularProgressIndicator(),
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
          top: MediaQuery.of(context).size.height * 0.22 - 100+ 220 + 86,
          left: MediaQuery.of(context).size.width * 0.06, 
          child: Container(
            width: MediaQuery.of(context).size.width * 0.89,
            height: MediaQuery.of(context).size.height * 0.15,
            padding: EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: shadeColor2.withOpacity(0.5), 
                width: 2, 
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
              padding: const EdgeInsets.only(left: 0.05), 
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
          top: MediaQuery.of(context).size.height * 0.22 - 100 + 220 + 100 + MediaQuery.of(context).size.height * 0.15 + 20, 
          left: MediaQuery.of(context).size.width * 0.126, 
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
                        width: 2), 
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
              SizedBox(width: 10), 
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
                        width: 2), 
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
                        ? NetworkImage(photoUrl)
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
                            _userProfileData?['picture'] = value;
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
            SizedBox(width: 10.0), 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.email, size: 20.0, color: Colors.black), 
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.phone, size: 20.0, color: Colors.black), 
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
            SizedBox(width: 10.0), 
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
