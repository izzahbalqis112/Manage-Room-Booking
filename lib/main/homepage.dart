import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tfrb_managerside/main/homepage/manageBooking/requestPendingBookingUser.dart';
import 'package:tfrb_managerside/main/searchPage.dart';
import 'package:tfrb_managerside/main/viewSelectedRoomData1.dart';
import '../Assets/Colors.dart';
import 'homepage/dataModel/roomStatus.dart';
import 'homepage/dataModel/rooms.dart';
import 'homepage/manageRoom/viewAllRoomData.dart';
import 'homepage/viewUserRatings/viewAllRatings.dart';

class Homepage extends StatefulWidget {

  Homepage({Key? key}) : super(key: key);
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>  with SingleTickerProviderStateMixin{
  late Future<List<RoomsModel>>? _roomsData;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _loadRoomsData();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadRoomsData() async {
      setState(() {
        _roomsData = _getRoomsData();
      });
  }

  void _reloadData() {
    setState(() {
      _loadRoomsData();
    });
  }

  Future<List<RoomsModel>> _getRoomsData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('roomsData').get();

      List<RoomsModel> roomsList = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> roomFacilities =
        List<String>.from(data['roomFacilities'] ?? []);

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

        double roomPrice = double.tryParse(data['roomPrice']) ?? 0.0;

        roomsList.add(RoomsModel(
          roomID: data['roomID'],
          images: List<String>.from(data['images'] ?? []),
          name: data['name'],
          about: data['about'],
          capacity: data['capacity'],
          roomStatus: roomStatus1,
          roomPrice: roomPrice,
          roomFacilities: roomFacilities,
          roomArea: data['roomArea'] ?? 0.0,
        ));
      }
      roomsList.sort((a, b) => a.name.compareTo(b.name));
      return roomsList;
    } else {
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: shadeColor2,
        toolbarHeight: 80,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 26, left: 4, right: 8),
              child: Container(
                width: 50, 
                height: 50, 
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Image.asset(
                    'lib/assets/img/TF-logo1.png', 
                    width: 30, 
                    height: 30,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28, left: 5),
              child: Text(
                'Teaching Factory',
                style: GoogleFonts.getFont(
                  'Roboto', 
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/img/Teaching Factory Design.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 30,
            right: 30,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
              child: AbsorbPointer(
                absorbing: true, 
                child: TextField(
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search rooms...',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: shadeColor6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            top: 130,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Rooms',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 218), 
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewAllRoomDataPage(
                              onClose: _reloadData,
                            ),
                          ),
                        );

                      },
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 14,
                          color: shadeColor3,
                        ),
                      ),
                    ),
                  ],
                ),
                FutureBuilder<List<RoomsModel>>(
                  future: _roomsData,
                  builder: (context, snapshot) {
                    if (_roomsData == null) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else {
                      List<RoomsModel> rooms = snapshot.data!;
                      return SizedBox(
                        height: 260,
                        width: MediaQuery.of(context).size.width - 60,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: rooms.map((room) => RoomContainer(room: room)).toList(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 550,
            left: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RequestPendingBookingPage(initialTabIndex: 0)),
                );
              },
              child: Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  color: shadeColor2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.book,
                      size: 50,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Manage User',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Booking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 550,
            right: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewAllRatingsPage()),
                );
              },
              child: Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  color: shadeColor2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 50,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'User Ratings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoomContainer extends StatelessWidget {
  final RoomsModel room;

  const RoomContainer({
    required this.room,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewSelectedRoomData1Page(roomID: room.roomID),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: 20),
        width: 200,
        height: 250,
        decoration: BoxDecoration(
          color: shadeColor3,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: shadeColor2,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: room.images.isNotEmpty ? room.images[0] : '', 
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover, 
                  placeholder: (context, url) => CircularProgressIndicator(), 
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(height: 20), 
            Text(
              room.name, 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

