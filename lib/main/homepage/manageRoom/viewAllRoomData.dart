import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:tfrb_managerside/main/homepage/manageRoom/viewSelectedRoomData.dart';
import '../../../assets/Colors.dart';
import '../../bottomnavbar/navbar.dart';
import '../dataModel/roomStatus.dart';
import '../dataModel/rooms.dart';
import 'addNewRoom.dart';
import 'editSelectedRoomData.dart';

class ViewAllRoomDataPage extends StatefulWidget {
  final VoidCallback? onClose;

  ViewAllRoomDataPage({this.onClose});

  @override
  _ViewAllRoomDataPageState createState() => _ViewAllRoomDataPageState();
}

class _ViewAllRoomDataPageState extends State<ViewAllRoomDataPage> with SingleTickerProviderStateMixin {
  late Future<List<RoomsModel>> _roomsData;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRoomsData();
  }

  Future<void> _loadRoomsData() async {
    setState(() {
      _roomsData = _getRoomsData();
    });
  }

  void _reloadData() {
    setState(() {
      _roomsData = _getRoomsData();
    });
  }

  Future<List<RoomsModel>> _getRoomsData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('roomsData')
          .get();

      List<RoomsModel> roomsList = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> roomFacilities = List<String>.from(data['roomFacilities'] ?? []);

        String roomStatus = data['roomStatus'];
        RoomStatusModel roomStatus1 = roomStatusList.firstWhere(
              (status) => status.roomStatus == roomStatus,
          orElse: () => RoomStatusModel(
            roomStatusID: '',
            roomStatus: 'Unknown',
            sortOrder: 0,
            active: false,
          ),
        );

        String formattedRoomPrice = data['roomPrice'];
        double roomPrice = double.tryParse(formattedRoomPrice.substring(3)) ?? 0.0;
        roomsList.add(RoomsModel(
          roomID: data['roomID'],
          images: List<String>.from(data['images'] ?? []),
          name: data['name'],
          about: data['about'],
          capacity: data['capacity'],
          roomStatus: roomStatus1,
          roomPrice: roomPrice,
          roomFacilities: roomFacilities,
          roomArea: data['roomArea'],
        ));
      }

      roomsList.sort((a, b) => a.name.compareTo(b.name));

      return roomsList;
    } else {
      return [];
    }
  }


  void _startTimer(List<RoomsModel> rooms) {
    Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % rooms.length;
      });
    });
  }

  IconData _getFacilityIcon(String facility) {
    switch (facility.toLowerCase()) {
      case 'electric':
        return EvaIcons.flash;
      case 'water':
        return EvaIcons.droplet;
      case 'crane':
        return Icons.fire_truck;
      case 'table':
        return Icons.table_bar;
      case 'chair':
        return Icons.chair;
      case 'aircon':
        return EvaIcons.thermometerMinus;
      default:
        return EvaIcons.questionMarkCircle;
    }
  }

  void _showBottomSheetDialog(BuildContext context, RoomsModel room) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit, color: shadeColor2),
                title: Text('Edit', style: TextStyle(color: shadeColor2, fontWeight: FontWeight.bold),),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateRoomDataPage(
                        onSaveComplete: () {
                          _loadRoomsData();
                        },
                        roomID: room.roomID,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                onTap: () {
                  _deleteRoom(room.roomID);
                  Navigator.pop(context);
                  _reloadData();                },
              ),
              ListTile(
                leading: Icon(Icons.visibility, color: shadeColor5),
                title: Text('View', style: TextStyle(color: shadeColor5, fontWeight: FontWeight.bold),),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewSelectedRoomDataPage(
                        roomID: room.roomID,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteRoom(String roomId) async {
    try {
      await FirebaseFirestore.instance
          .collection('roomsData')
          .doc(roomId)
          .delete();
      print('Room deleted successfully!');
      setState(() {
        _roomsData = _getRoomsData();
      });
    } catch (error) {
      print('Error deleting room: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shadeColor3,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: shadeColor3,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: shadeColor2),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ButtomNavBar(),
              ),
            );
            widget.onClose?.call();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddNewRoomDataPage(
                        onSaveComplete: () {
                          _loadRoomsData();
                        },
                      ),
                    ),
                  );
                },
                child: Text(
                  'Add New Room',
                  style: TextStyle(
                    color: shadeColor2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body:FutureBuilder<List<RoomsModel>>(
        future: _roomsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text('Error: Unable to fetch data'),
            );
          } else {
            final rooms = snapshot.data!;
            _startTimer(rooms);
            return SingleChildScrollView(
              child: Column(
                children: rooms.map((room) {
                  return GestureDetector(
                    onTap: () {
                      _showBottomSheetDialog(context, room);
                    },
                    child: Container(
                      height: 370,
                      width: 400,
                      decoration: BoxDecoration(
                        color: shadeColor2,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                              child: Container(
                                height: 180,
                                width: 400,
                                child: PageView.builder(
                                  itemCount: room.images.length,
                                  controller: PageController(
                                    initialPage: _currentIndex,
                                  ),
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return AnimatedSwitcher(
                                      duration: Duration(milliseconds: 500),
                                      child: CachedNetworkImage(
                                        imageUrl: room.images[index],
                                        fit: BoxFit.cover,
                                        height: 200,
                                        width: 400,
                                        placeholder: (context, url) => CircularProgressIndicator(),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 80,
                            left: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  width: 360,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      room.about,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                      maxLines: 3, 
                                      overflow: TextOverflow.ellipsis, 
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10), 
                                Container(
                                  width: 360,
                                  child: SingleChildScrollView( 
                                    scrollDirection: Axis.horizontal, 
                                    child: Row(
                                      children: room.roomFacilities?.map((facility) {
                                        return Row(
                                          children: [
                                            Icon(
                                              _getFacilityIcon(facility),
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              facility,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                          ],
                                        );
                                      }).toList() ?? [],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 15,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'RM ' + room.roomPrice.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 5), 
                                    Text(
                                      '/day', 
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
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
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
