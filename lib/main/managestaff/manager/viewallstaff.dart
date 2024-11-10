import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../managerModel.dart';
import '../addNewStaff.dart';
import 'package:tfrb_managerside/Assets/Colors.dart';

import 'editSelectedManagerID.dart';

class ViewAllManager extends StatefulWidget {
  @override
  _ViewAllManagerState createState() => _ViewAllManagerState();
}

class _ViewAllManagerState extends State<ViewAllManager> {
  bool _selectAll = false;
  List<String> _selectedItems = []; // Track selection state for each item
  late Future<List<ManagerModel>> _staffData;

  @override
  void initState() {
    super.initState();
    _staffData = _getStaffData();
  }

  Future<List<ManagerModel>> _getStaffData() async {
    // Fetch staff data from Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('managersAccount').get();

    // Convert each document snapshot to ManagerModel object
    List<ManagerModel> staffList = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return ManagerModel(
        firstName: data['firstName'],
        lastName: data['lastName'],
        email: data['email'],
        managerID: data['managerID'],
        picture: data['picture'],
        utemStaffID: data['utemStaffID'],
        role: (data['role']),
        password: data['password'],
      );
    }).toList();

    return staffList;
  }

  // Method to delete all staff data
  Future<void> _deleteAllStaffData() async {
    try {
      await FirebaseFirestore.instance.collection('managersAccount').get().then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      setState(() {
        _staffData = _getStaffData(); // Refresh staff data
      });
    } catch (error) {
      print('Error deleting all staff data: $error');
    }
  }

  // Method to delete selected manager ID data
  Future<void> _deleteSelectedManagerData(String managerID, String currentUserEmail) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('managersAccount').doc(managerID).get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      String managerEmail = data['email'];

      if (managerEmail == currentUserEmail) {
        // If the email matches, skip deletion and display a message or handle it as needed
        print('Current user cannot delete their own profile.');
        return;
      }

      await FirebaseFirestore.instance.collection('managersAccount').doc(managerID).delete();

      setState(() {
        _staffData = _getStaffData();
        _selectAll = false;
      });
    } catch (error) {
      print('Error deleting selected manager data: $error');
      // Handle error as needed
    }
  }


  // Method to toggle selection of all manager IDs
  void _toggleSelectAll(bool value, List<ManagerModel> staffList) {
    setState(() {
      _selectAll = value;
      if (value) {
        _selectedItems = staffList.map((manager) => manager.managerID).toList();
      } else {
        _selectedItems.clear();
      }
    });
  }

  // Method to show a pop-up message
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Manager added successfully! Please remember to insert the manager's email and password into Firebase Auth."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: false,
    body: Container(
      color: shadeColor3,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context); // Navigate to the previous page
              },
            ),
          ),
          Positioned.fill(
            top: 95,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/img/profile.png'),
                  fit: BoxFit.cover,
                ),
              ),

              child: FutureBuilder<List<ManagerModel>>(
                future: _staffData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        ManagerModel staff = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedItems.contains(staff.managerID)) {
                                _selectedItems.remove(staff.managerID);
                              } else {
                                _selectedItems.add(staff.managerID);
                              }
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: shadeColor2,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: shadeColor4,
                                      width: 2.0,
                                    ),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: staff.picture != null
                                          ? NetworkImage(staff.picture!)
                                          : AssetImage('lib/assets/img/profile.png') as ImageProvider,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${staff.firstName} ${staff.lastName}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Role: ${staff.role}',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    Text(
                                      'ID: ${staff.utemStaffID}',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Checkbox(
                                  value: _selectedItems.contains(staff.managerID),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value != null) {
                                        if (value) {
                                          _selectedItems.add(staff.managerID);
                                        } else {
                                          _selectedItems.remove(staff.managerID);
                                        }
                                      }
                                    });
                                  },
                                  checkColor: Colors.white, // Color of the check mark
                                  fillColor: MaterialStateProperty.resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                      if (states.contains(MaterialState.selected)) {
                                        return shadeColor2; // Background color when checked
                                      }
                                      return Colors.transparent; // Background color when unchecked
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _selectAll,
                    onChanged: (value) async {
                      List<ManagerModel> staffList = await _staffData;
                      _toggleSelectAll(value!, staffList);
                    },
                  ),
                  Text('Select All'),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      if (_selectAll) {
                        Fluttertoast.showToast(
                          msg: "Please select one manager to proceed with the edit method",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else {
                        // If specific items are selected, edit only the selected staff data
                        for (String managerID in _selectedItems) {
                          // Navigate to the EditSelectedManagerData page with the selected manager ID
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditSelectedManagerData(managerID: managerID),
                            ),
                          );
                          // Check if the edit was successful and reload the staff data
                          if (result == true) {
                            setState(() {
                              _staffData = _getStaffData(); // Refresh staff data
                            });
                          }
                        }
                      }
                    },
                    child: Text(
                      'Edit',
                      style: TextStyle(color: shadeColor2, fontWeight: FontWeight.bold),
                    ),
                  ),

                  TextButton(
                    onPressed: () async {
                      if (_selectAll) {
                        // If "Select All" is checked, delete all staff data
                        await _deleteAllStaffData();
                      } else {
                        // If specific items are selected, delete only the selected staff data
                        for (String managerID in _selectedItems) {
                          await _deleteSelectedManagerData(managerID, FirebaseAuth.instance.currentUser!.email!);
                        }
                      }
                      // After deletion, refresh the staff data
                      setState(() {
                        _staffData = _getStaffData();
                      });
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: Padding(
      padding: const EdgeInsets.only(bottom: 60.0),
      child: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          backgroundColor: shadeColor2,
          onPressed: () async {
            // Navigate to the AddNewStaffPage and wait for the result
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNewStaffPage()),
            );
            if (result == true) {
              setState(() {
                _staffData = _getStaffData(); // Refresh staff data if new staff added
              });
              _showSuccessDialog(context); // Show success dialog
            }
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    ),
  );
}