import 'package:flutter/material.dart';

import 'auth/login.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/img/First page.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //TF logo
            Align(
              alignment: Alignment.topCenter, // Align the logo to the top center
              child: Padding(
                padding: const EdgeInsets.only(top: 150, bottom: 20), // Adjust the top padding for positioning
                child: Image.asset(
                  'lib/assets/img/TF-logo.png',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            Column(
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.displayMedium,
                    children: [
                      TextSpan(
                        text: "Teaching Factory",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                    height:
                    10), // Adjust the space between "Teaching Factory" and the new text
                Text(
                  "The Learning Organization",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(
                    height:
                    240), //
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    vertical: 16, horizontal: 104), // Adjust padding for size
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(44), // Adjust border radius
                  side: BorderSide(
                      color: Colors.white, width: 2), // Border color and width
                ),
                elevation: 5, //shadow
              ),
              child: Text(
                "Log in",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
