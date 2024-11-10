import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../Assets/Colors.dart';
import '../dataModel/roomStatus.dart';
import 'package:path/path.dart' as Path;
import '../dataModel/rooms.dart';


class UpdateRoomDataPage extends StatefulWidget {
  final VoidCallback onSaveComplete;
  final String roomID;

  UpdateRoomDataPage({required this.roomID, required this.onSaveComplete});

  @override
  _UpdateRoomDataPageState createState() => _UpdateRoomDataPageState();
}

class _UpdateRoomDataPageState extends State<UpdateRoomDataPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _roomFacilitiesController = TextEditingController();
  final TextEditingController _roomAreaController = TextEditingController();
  final TextEditingController _roomPriceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _newImageFiles;
  List<String>? _existingImageFiles;
  String? _selectedRoomStatus;
  bool _isNameValid = true;
  bool _isAboutValid = true;
  String roomID = Uuid().v4();
  int _capacity = 0;
  List<String> roomFacilities = ['Electric', 'Water', 'Crane', 'Table', 'Chair', 'Aircon'];
  List<String> allFacilities = ['Electric', 'Water', 'Crane', 'Table', 'Chair', 'Aircon'];
  static const double pricePerSquareMeter = 22.10;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _existingImageFiles = [];
    _newImageFiles = [];
    _roomAreaController.addListener(_calculateRoomPrice);
    _loadRoomData();
  }

  Future<String> getDownloadURL(String imagePath) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref(imagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error fetching image URL: $e');
      // Handle the error, perhaps by logging or showing a message
      return ''; // Returning an empty string or a placeholder URL
    }
  }

  void _loadRoomData() async {
    try {
      // Fetch room data from Firestore using roomID
      DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
          .collection('roomsData')
          .doc(widget.roomID)
          .get();

      if (roomSnapshot.exists) {
        // Check if room data exists
        Map<String, dynamic> data = roomSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = data['name'];
          _aboutController.text = data['about'];
          _capacityController.text = data['capacity'].toString();
          _selectedRoomStatus = data['roomStatus'];
          _roomFacilitiesController.text = (data['roomFacilities'] as List<dynamic>?)?.join(', ') ?? '';
          _roomAreaController.text = data['roomArea'].toString();
          _roomPriceController.text = data['roomPrice'].toString();

          _existingImageFiles = (data['images'] as List<dynamic>?)?.cast<String>() ?? [];
        });
      } else {
        Fluttertoast.showToast(msg: "Room data not found");
      }
    } catch (e) {
      print('Error fetching room data: $e');
      Fluttertoast.showToast(msg: 'Error fetching room data: $e');
    }
  }

  bool _validateName(String value) {
    return value.isNotEmpty;
  }

  bool _validateAbout(String value) {
    return value.isNotEmpty;
  }

  void _incrementCapacity() {
    setState(() {
      _capacity++;
      _capacityController.text = _capacity.toString();
    });
  }

  void _decrementCapacity() {
    setState(() {
      if (_capacity > 0) {
        _capacity--;
        _capacityController.text = _capacity.toString();
      }
    });
  }

  void _showFacilitiesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> selectedFacilities = List.from(roomFacilities); // Make a copy of current room facilities

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Room Facilities'),
              content: SingleChildScrollView(
                child: Column(
                  children: allFacilities.map((facility) {
                    return CheckboxListTile(
                      title: Text(facility),
                      value: selectedFacilities.contains(facility),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value!) {
                            selectedFacilities.add(facility);
                          } else {
                            selectedFacilities.remove(facility);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close', style: TextStyle(color: shadeColor5)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      roomFacilities = List.from(selectedFacilities); // Update room facilities with selected facilities
                      _roomFacilitiesController.text = roomFacilities.join(', '); // Update the text field with selected facilities
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? selected = await _picker.pickImage(source: source);
      if (selected != null) {
        setState(() {
          _newImageFiles = [...?_newImageFiles, selected];
        });
      }
    } catch (e) {
      // Handle errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<String>> uploadImages(List<File> images) async {
    var uploadTasks = images.map((image) async {
      String fileName = Path.basename(image.path);
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('roomImages/$roomID/$fileName');


      var uploadTask = ref.putFile(image);
      var imageUrl = await (await uploadTask).ref.getDownloadURL();
      return imageUrl;
    }).toList();

    return Future.wait(uploadTasks);
  }

  Future<void> _saveRoom(String? roomID) async {
    try {
      List<String> newImageUrls = [];
      if (_newImageFiles != null && _newImageFiles!.isNotEmpty) {
        newImageUrls = await uploadImages(_newImageFiles!.map((xFile) => File(xFile.path)).toList());
      }

      // Combine existing and new image URLs
      List<String> allImageUrls = [
        if (_existingImageFiles is List<String>) ...?_existingImageFiles,
        ...newImageUrls, // These are URLs of newly uploaded images (Strings)
      ];

      RoomStatusModel? selectedRoomStatusModel;
      if (_selectedRoomStatus != null) {
        selectedRoomStatusModel = roomStatusList.firstWhere(
              (status) => status.roomStatus == _selectedRoomStatus,
          orElse: () => RoomStatusModel(
            roomStatusID: '',
            roomStatus: _selectedRoomStatus!, // Set the room status directly
            sortOrder: 0,
            active: false, // Set active to false by default
          ),
        );
      }

      List<String> roomFacilitiesList = _roomFacilitiesController.text.split(', ');

      int capacity = int.tryParse(_capacityController.text) ?? 0;

      setState(() {
        _existingImageFiles = [...?_existingImageFiles, ...newImageUrls];
        _newImageFiles = []; // Clear new images list after merging
      });

      double roomPrice = double.tryParse(_roomPriceController.text.trim().substring(2)) ?? 0.0;

      RoomsModel roomsModel = RoomsModel(
        images: allImageUrls,
        roomID: widget.roomID,
        name: _nameController.text,
        about: _aboutController.text,
        capacity: capacity,
        roomStatus: selectedRoomStatusModel ?? RoomStatusModel(
          roomStatusID: '',
          roomStatus: '', // Set the room status directly
          sortOrder: 0,
          active: false, // Set active to false by default
        ),
        roomFacilities: roomFacilitiesList,
        roomArea: double.tryParse(_roomAreaController.text.trim()) ?? 0.0,
        roomPrice: roomPrice, // Store the price as a double
      );

      // Format the room price
      String formattedRoomPrice = 'RM ' + roomPrice.toStringAsFixed(2);

      Map<String, dynamic> roomsData = {
        'roomID': roomsModel.roomID,
        'name': roomsModel.name,
        'name_lowercase': roomsModel.name.toLowerCase(),
        'about': roomsModel.about,
        'capacity': roomsModel.capacity,
        'roomStatus': roomsModel.roomStatus.roomStatus,
        'roomPrice': formattedRoomPrice, // Save the formatted room price
        'roomFacilities': roomsModel.roomFacilities,
        'roomArea': roomsModel.roomArea,
        'images': roomsModel.images,
      };

      await _firestore.collection('roomsData').doc(roomsModel.roomID).set(roomsData);

      widget.onSaveComplete();
      // Navigate back
      Navigator.pop(context, true);
    } catch (e) {
      _showErrorMessage('Failed to save journal entry: $e');
    }
  }


  void _showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _capacityController.dispose();
    _roomFacilitiesController.dispose();
    _roomAreaController.dispose();
    _roomPriceController.dispose();
    super.dispose();
  }

  void _calculateRoomPrice() {
    String? roomAreaText = _roomAreaController.text.trim();
    if (roomAreaText.isNotEmpty) {
      // Parse room area to double
      double roomArea = double.tryParse(roomAreaText) ?? 0.0;
      // Calculate room price
      double roomPrice = roomArea * pricePerSquareMeter; // Use the provided price per square meter
      // Update room price controller with formatted price
      _roomPriceController.text = 'RM${roomPrice.toStringAsFixed(2)}';
    } else {
      // If room area is empty, clear room price
      _roomPriceController.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Update Room Details',
          style: TextStyle(color: shadeColor2, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: shadeColor2),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _saveRoom(widget.roomID);
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: shadeColor2, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
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
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned(
                            top: 60,
                            left: 35,
                            child: Container(
                              padding: EdgeInsets.only(left: 0.05),
                              width: MediaQuery.of(context).size.width - 80,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        borderSide: BorderSide(
                                          color: _isNameValid ? shadeColor1 : Colors.red,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _isNameValid ? shadeColor1 : Colors.red,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      hintText: "Name",
                                      hintStyle: TextStyle(color: shadeColor3),
                                      prefixIcon: Icon(Icons.email, color: Colors.white,),
                                      fillColor: shadeColor2,
                                      filled: true,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _isNameValid = _validateName(value);
                                      });
                                    },
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  if (!_isNameValid)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                                      child: Text(
                                        'Name cannot be empty',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 14),
                                  TextField(
                                    controller: _aboutController,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        borderSide: BorderSide(
                                          color: _isAboutValid ? shadeColor1 : Colors.red,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _isAboutValid ? shadeColor1 : Colors.red,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      hintText: "About",
                                      hintStyle: TextStyle(color: shadeColor3),
                                      prefixIcon: Icon(Icons.person, color: Colors.white,),
                                      fillColor: shadeColor2,
                                      filled: true,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _isAboutValid = _validateAbout(value);
                                      });
                                    },
                                    keyboardType: TextInputType.multiline,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  if (!_isAboutValid)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                                      child: Text(
                                        'About cannot be empty',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _capacityController,
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: shadeColor1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: shadeColor1,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            hintText: "Capacity",
                                            hintStyle: TextStyle(color: shadeColor3),
                                            prefixIcon: Icon(Icons.reduce_capacity, color: Colors.white,),
                                            suffixIcon: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: _incrementCapacity,
                                                  icon: Icon(Icons.arrow_drop_up, color: Colors.white,),
                                                ),
                                                IconButton(
                                                  onPressed: _decrementCapacity,
                                                  icon: Icon(Icons.arrow_drop_down, color: Colors.white,),
                                                ),
                                              ],
                                            ),
                                            fillColor: shadeColor2,
                                            filled: true,
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 14),
                                  DropdownButtonFormField<String>(
                                    value: _selectedRoomStatus,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRoomStatus = value;
                                      });
                                    },
                                    items: roomStatusList.map((RoomStatusModel status) {
                                      return DropdownMenuItem<String>(
                                        value: status.roomStatus,
                                        child: Text(status.formattedStatus(),
                                          style: TextStyle(color: Colors.white),),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        borderSide: BorderSide(
                                          color: shadeColor1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: shadeColor1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      hintText: "Room Status",
                                      hintStyle: TextStyle(color: shadeColor3),
                                      fillColor: shadeColor2,
                                      prefixIcon: Icon(Icons.room, color: Colors.white,),
                                      filled: true,
                                    ),
                                    dropdownColor: shadeColor5,
                                    iconEnabledColor: Colors.white,
                                  ),
                                  SizedBox(height: 14),
                                  GestureDetector(
                                    onTap: () {
                                      _showFacilitiesDialog(context);
                                    },
                                    child: AbsorbPointer(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(32),
                                            borderSide: BorderSide(
                                              color: shadeColor1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: shadeColor1,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          hintText: "Room Facility",
                                          hintStyle: TextStyle(color: shadeColor3),
                                          prefixIcon: Icon(EvaIcons.homeOutline, color: Colors.white),
                                          fillColor: shadeColor2,
                                          filled: true,
                                        ),
                                        keyboardType: TextInputType.text,
                                        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                                        style: TextStyle(color: Colors.white),
                                        readOnly: true,
                                        controller: _roomFacilitiesController,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 14),
                                  TextField(
                                    controller: _roomAreaController,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        borderSide: BorderSide(
                                          color: shadeColor1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: shadeColor1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      hintText: "Room Area (m²)",
                                      hintStyle: TextStyle(color: shadeColor3),
                                      prefixIcon: Icon(EvaIcons.layersOutline, color: Colors.white,),
                                      fillColor: shadeColor2,
                                      filled: true,
                                    ),
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(height: 14),
                                  TextField(
                                    controller: _roomPriceController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        borderSide: BorderSide(
                                          color: shadeColor1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: shadeColor1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      hintText: "Room Price",
                                      hintStyle: TextStyle(color: shadeColor3),
                                      prefixIcon: Icon(EvaIcons.pricetags, color: Colors.white,),
                                      fillColor: shadeColor2,
                                      filled: true,
                                    ),
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      ElevatedButton.icon(
                                        onPressed: () => _pickImage(ImageSource.camera),
                                        icon: Icon(Icons.camera, color: Colors.white,),
                                        label: Text("Camera", style: TextStyle(color: shadeColor3)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: shadeColor2, // Use your color
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => _pickImage(ImageSource.gallery),
                                        icon: Icon(Icons.image, color: Colors.white,),
                                        label: Text("Gallery", style: TextStyle(color: shadeColor3)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: shadeColor2, // Use your color
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  _buildImageDisplaySection(_existingImageFiles, _newImageFiles),
                                ],
                              ),
                            ),
                          ),
                        ],
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


  Widget _buildImageDisplaySection(List<dynamic>? existingImages, List<dynamic>? newImages) {
    List<dynamic> allImages = [];

    // Combine existing and new images into one list
    if (existingImages != null) {
      allImages.addAll(existingImages);
    }
    if (newImages != null) {
      allImages.addAll(newImages);
    }

    if (allImages.isEmpty) {
      return SizedBox.shrink(); // or some other widget that represents an empty state
    }

    double _currentXOffset = 0.0;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _currentXOffset += details.delta.dx;
        });
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Transform.translate(
          offset: Offset(_currentXOffset, 0.0),
          child: Row(
            children: allImages.asMap().entries.map((entry) {
              var image = entry.value;

              Widget imageWidget = (image is String)
                  ? CachedNetworkImage(
                imageUrl: image,
                width: 180,
                height: 180,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              )
                  : Image.file(File(image.path), width: 180, height: 180, fit: BoxFit.cover);

              return Padding(
                padding: EdgeInsets.all(8),
                child: Stack(
                  children: [
                    imageWidget,
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
