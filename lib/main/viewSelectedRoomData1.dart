import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../assets/Colors.dart';
import 'SelectedUsersRatingsBasedOnRoomIDPage.dart';
import 'bottomnavbar/navbar.dart';
import 'homepage/dataModel/roomStatus.dart';
import 'homepage/dataModel/rooms.dart';
import 'homepage/manageRoom/editSelectedRoomData.dart';

class ViewSelectedRoomData1Page extends StatefulWidget {
  final String roomID;

  ViewSelectedRoomData1Page({required this.roomID});

  @override
  _ViewSelectedRoomData1PageState createState() =>
      _ViewSelectedRoomData1PageState();
}

class _ViewSelectedRoomData1PageState extends State<ViewSelectedRoomData1Page> {
  late Future<RoomsModel?> _roomData;
  double? _averageRating;
  int? _totalRatings;

  @override
  void initState() {
    super.initState();
    _loadRoomData();
  }

  Future<void> _loadRoomData() async {
    setState(() {
      _roomData = _getRoomData();
    });

    try {
      Map<String, dynamic> ratingsData = await _getRatingsData(widget.roomID);
      setState(() {
        _averageRating = ratingsData['averageRating'];
        _totalRatings = ratingsData['totalRatings'];
      });
    } catch (error) {
      print('Error loading room data: $error');
    }
  }

  Future<Map<String, dynamic>> fetchRatingsData(String roomID) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('roomBookingData')
        .where('room.roomID', isEqualTo: roomID)
        .where('bookingStatus.status', isEqualTo: 'Completed')
        .get();

    double totalRating = 0;
    int totalRatings = 0;
    if (snapshot.docs.isNotEmpty) {
      totalRatings = snapshot.docs.length;
      snapshot.docs.forEach((doc) {
        totalRating += (doc['bookingRatings']['userRating'] ?? 0).toDouble();
      });
    }

    double averageRating = totalRatings > 0 ? totalRating / totalRatings : 0.0;
    return {
      'totalRatings': totalRatings,
      'averageRating': averageRating,
    };
  }

  Future<Map<String, dynamic>> _getRatingsData(String roomID) async {
    try {
      Map<String, dynamic> ratingsData = await fetchRatingsData(roomID);
      return ratingsData;
    } catch (error) {
      print('Error fetching ratings data: $error');
      throw error;
    }
  }


  Future<RoomsModel?> _getRoomData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('roomsData')
          .doc(widget.roomID)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
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
        double roomPrice = 0.0;
        if (formattedRoomPrice.startsWith('RM ')) {
          roomPrice = double.tryParse(formattedRoomPrice.substring(3)) ?? 0.0;
        }

        return RoomsModel(
          roomID: data['roomID'],
          images: List<String>.from(data['images'] ?? []),
          name: data['name'],
          about: data['about'],
          capacity: data['capacity'],
          roomStatus: roomStatus1,
          roomPrice: roomPrice, 
          roomFacilities: roomFacilities,
          roomArea: data['roomArea'],
        );
      }
    }
    return null;
  }

  final Map<String, IconData> facilityIcons = {
    'Electric': EvaIcons.flash,
    'Water': EvaIcons.droplet,
    'Crane': Icons.fire_truck,
    'Table': Icons.table_bar,
    'Chair': Icons.chair,
    'Aircon': EvaIcons.thermometerMinus,
  };

  void _deleteRoom(String roomId) async {
    try {
      await FirebaseFirestore.instance
          .collection('roomsData')
          .doc(roomId)
          .delete();
      print('Room deleted successfully!');
      setState(() {
        _roomData = _getRoomData();
      });
    } catch (error) {
      print('Error deleting room: $error');
    }
  }

  void _reloadData() {
    setState(() {
      _roomData = _getRoomData();
    });
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this room?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteRoom(widget.roomID);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ButtomNavBar(),
                  ),
                );
                _reloadData();
              },
              child: Text('Proceed'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<RoomsModel?>(
        future: _roomData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null) {
            return Center(child: Text('Room not found'));
          } else {
            RoomsModel roomData = snapshot.data!;
            return Container(
              height: double.infinity,
              width: double.infinity,
              color: shadeColor6,
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            _topImages(roomData),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    top: 50, left: 20, right: 20),
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: shadeColor6.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(40),
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                padding: const EdgeInsets.only(
                                    top: 30, right: 30, left: 30),
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: shadeColor6.withOpacity(0.4),
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(50),
                                        topRight: Radius.circular(50))),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              roomData.name,
                                              style: TextStyle(
                                                  fontSize: 26,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  decoration:
                                                  TextDecoration.none),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              roomData.roomStatus.roomStatus,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.white
                                                      .withOpacity(.5),
                                                  decoration:
                                                  TextDecoration.none),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => SelectedUsersRatingsBasedOnRoomIDPage(
                                                      roomID: widget.roomID,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: TextButton(
                                                onPressed: null,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      color: Colors.orange,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      _averageRating != null
                                                          ? _averageRating!.toStringAsFixed(1) 
                                                          : 'N/A',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      '($_totalRatings)',
                                                      style: TextStyle(
                                                        color: Colors.white.withOpacity(.5),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20, left: 20, right: 30),
                          width: double.infinity,
                          child: Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "About",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(.5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    roomData.about,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    "Facilities",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(.5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          for (String facility in roomData.roomFacilities ?? [])
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                              child: buildFacility(facility),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30,),
                                  Text(
                                    "Area (m²)",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(.5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    roomData.roomArea.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 30,),
                                  Text(
                                    "Capacity",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(.5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    roomData.capacity.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 30,),
                                  Text(
                                    "Price ",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(.5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'RM ${roomData
                                        .roomPrice} /day',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: _showDeleteConfirmationDialog,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red, 
                                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          'Delete Room',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UpdateRoomDataPage(
                                                onSaveComplete: () {
                                                  _reloadData();
                                                },
                                                roomID: widget.roomID,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          'Update Room',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),

                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Hero _topImages(RoomsModel roomData) {
    PageController _pageController = PageController(initialPage: 0);

    return Hero(
      tag: 'hero1',
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: roomData.images.length,
            itemBuilder: (context, index) {
              return AspectRatio(
                aspectRatio: 16 / 15,
                child: CachedNetworkImage( 
                  imageUrl: roomData.images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(), 
                  errorWidget: (context, url, error) => Icon(Icons.error), 
                ),
              );
            },
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_pageController.page! > 0) {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: shadeColor6.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    if (_pageController.page! < roomData.images.length - 1) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: shadeColor6.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFacility(String facilityName) {
    IconData iconData = facilityIcons[facilityName] ?? EvaIcons.questionMarkCircleOutline;
    return Column(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            iconData,
            color: shadeColor2,
            size: 20,
          ),
        ),
        SizedBox(height: 5),
        Text(
          facilityName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
