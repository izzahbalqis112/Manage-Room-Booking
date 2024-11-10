import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:tfrb_managerside/Assets/Colors.dart';

class PDFViewerPage extends StatefulWidget {
  final String bookingId;

  PDFViewerPage({required this.bookingId});

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  List<dynamic> fileDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchPDFDetails();
  }

  Future<void> _fetchPDFDetails() async {
    try {
      DocumentSnapshot bookingDoc = await FirebaseFirestore.instance
          .collection('roomBookingData')
          .doc(widget.bookingId)
          .get();

      setState(() {
        fileDetails = bookingDoc['paymentDetails'] ?? [];
      });
    } catch (e) {
      print('Error fetching payment details: $e');
    }
  }

  void _viewPDF(String fileURL, String fileName) async {
    try {
      final response = await http.get(Uri.parse(fileURL));
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(response.bodyBytes);

      OpenFile.open(filePath);
    } catch (e) {
      print('Error viewing PDF: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: shadeColor2,
        title: Text('PDF Viewer', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Please tap on a PDF file to view it, or download it if needed:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: fileDetails.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: fileDetails.length,
              itemBuilder: (context, index) {
                var fileDetail = fileDetails[index];
                return ListTile(
                  leading: Icon(Icons.picture_as_pdf, color: Colors.red,),
                  title: Text(fileDetail['fileName'] ?? ''),
                  onTap: () {
                    _viewPDF(fileDetail['fileURL'] ?? '', fileDetail['fileName'] ?? '');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
