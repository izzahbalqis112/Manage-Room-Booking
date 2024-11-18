import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:firebase_storage/firebase_storage.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Assets/Colors.dart';

class EditPicture extends StatefulWidget {
  @override
  _EditPictureState createState() => _EditPictureState();
}

class _EditPictureState extends State<EditPicture> {
  File? _selectedImage;
  bool _isUploading = false;
  String? _photoUrl;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUser = currentUser;
      });
      await fetchUserProfilePhoto(currentUser.uid);
    }
  }

  Future<void> fetchUserProfilePhoto(String managerId) async {
    try {
      DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
          .collection('managersAccount')
          .doc(managerId)
          .get();

      if (userDataSnapshot.exists) {
        Map<String, dynamic> userData = userDataSnapshot.data() as Map<String, dynamic>;
        if (userData['picture'] != null && userData['picture'] != '') {
          setState(() {
            _photoUrl = userData['picture'];
          });
        }
      } else {
        print('User data does not exist.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 60.0),
            Center(
              child: GestureDetector(
                onTap: _selectImage,
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
            SizedBox(height: 20.0),
            Container(
              child: ElevatedButton(
                onPressed: _saveProfileChanges,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 30
                  ),
                  backgroundColor: shadeColor2,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        44),
                    side: BorderSide(
                        color: shadeColor2,
                        width: 2), 
                  ),
                ),
                child: Text(
                  "Save Profile",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        _uploadUserProfilePhoto(); 
      });
    }
  }

  Future<String> _uploadUserProfilePhoto() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || _selectedImage == null) {
      throw Exception("No authenticated user found or image not selected");
    }

    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('managerProfilePhotos') 
        .child(currentUser.uid) 
        .child('${currentUser.uid}.jpg'); 

    final UploadTask uploadTask = storageRef.putFile(_selectedImage!);

    setState(() {
      _isUploading = true;
    });

    final TaskSnapshot uploadSnapshot = await uploadTask.whenComplete(() {});
    final String downloadUrl = await uploadSnapshot.ref.getDownloadURL();

    setState(() {
      _isUploading = false;
      _photoUrl = downloadUrl; 
    });

    return downloadUrl;
  }

  Future<void> _saveProfileChanges() async {
    try {
      String? userEmail = _currentUser.email;

      if (userEmail != null) {
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('managersAccount')
            .where('email', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentReference userDocRef = userQuerySnapshot.docs.first.reference;
          await userDocRef.update({
            'picture': _photoUrl, 
          })

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Picture updated successfully.'),
            ),
          );

          Navigator.pop(context, _photoUrl);
        } else {
          print('User document not found.');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }
}
