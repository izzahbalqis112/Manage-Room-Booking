import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:tfrb_managerside/main/viewSelectedRoomData1.dart';
import '../assets/Colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController searchController;
  List<String> searchResults = [];
  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<String>> _getRoomSearchResults(String query) async {
    List<String> results = [];
    String lowercaseQuery = query.toLowerCase();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('roomsData')
        .orderBy('name_lowercase')
        .startAt([lowercaseQuery])
        .endAt([lowercaseQuery + '\uf8ff']) 
        .get();
    querySnapshot.docs.forEach((doc) {
      results.add(doc['name']);
    });

    return results;
  }

  Widget _noResults(IconData icon, String input) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FaIcon(icon, size: 30, color: Colors.white,),
          Padding(padding: EdgeInsets.only(top: 10, bottom: 5)),
          Text(input, style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.symmetric(horizontal: 15),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.search, color: shadeColor6),
              ),
              Expanded(
                child: TextField(
                  controller: searchController,
                  cursorColor: shadeColor5,
                  cursorHeight: 20,
                  autofocus: true,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                    hintText: 'Search rooms...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) async {
                    var results = await showDialog(
                      context: context,
                      builder: (context) => FutureProgressDialog(_getRoomSearchResults(value)),
                    );
                    setState(() {
                      searchResults = results;
                      isSubmitted = true;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    isSubmitted = false;
                    searchController.clear();
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: isSubmitted && searchResults.isEmpty
              ? _noResults(FontAwesomeIcons.hourglass, "No rooms found..")
              : Container(),
        ),
      ],
    );
  }


  Widget _buildCombinedSearchResultList() {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        var roomName = searchResults[index];
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('roomsData').where('name', isEqualTo: roomName).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Container();
            }
            var roomID = snapshot.data!.docs.first.id;
            return ListTile(
              title: Text(
                roomName,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), 
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewSelectedRoomData1Page(roomID: roomID),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shadeColor2,
      appBar: AppBar(
        backgroundColor: shadeColor2,
        elevation: 0,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.close, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16),
            _buildSearchBar(),
            Expanded(
              child: isSubmitted ? _buildCombinedSearchResultList(): Container(),
            ),
          ],
        ),
      ),
    );
  }
}
