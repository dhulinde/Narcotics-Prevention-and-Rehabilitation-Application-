import 'package:flutter/material.dart';

// Colors
const Color kLightBlue = Color(0xFFECF0FB);
const Color kMediumBlue = Color(0xFFDBEAF7);
const Color kLightPink = Color(0xFFF6DFDB);
const Color kCoralRed = Color(0xFFE77D67);

// Text Styles
const TextStyle kTitleStyle = TextStyle(
  fontSize: 36,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

const TextStyle kLabelStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

const TextStyle kButtonTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const TextStyle kLinkTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: Colors.black54,
);

// Common Widgets
InputDecoration textFieldDecoration({
  required String hintText,
  required IconData prefixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey[400]),
    prefixIcon: Icon(prefixIcon, color: Colors.black),
    fillColor: Colors.white,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(color: Colors.grey, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(color: Colors.grey, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(color: Colors.blue, width: 1),
    ),
  );
}

Widget buildButton({
  required String text,
  required VoidCallback onPressed,
  Color backgroundColor = kCoralRed,
  double width = double.infinity,
}) {
  return SizedBox(
    width: width,
    height: 60,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: kButtonTextStyle,
      ),
    ),
  );
}

Widget buildBackButton(BuildContext context) {
  return SizedBox(
    width: 120,
    height: 60,
    child: ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: kCoralRed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_back, color: Colors.white),
          SizedBox(width: 5),
          Text('Back', style: kButtonTextStyle),
        ],
      ),
    ),
  );
}

// Screen Layout Helper
Widget buildScreenLayout({
  required BuildContext context,
  required String title,
  required List<Widget> children,
  bool showBackButton = true,
  String? subtitle,
}) {
  return Scaffold(
    body: Stack(
      children: [
        const BackgroundDecoration(),
        SafeArea(
          child: Column(
            children: [
              // App Bar with Back Button
              if (showBackButton)
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: buildBackButton(context),
                  ),
                ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          title,
                          style: kTitleStyle,
                          textAlign: TextAlign.center,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 15),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 40),
                        ...children,
                      ],
                    ),
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

// Background Decoration
class BackgroundDecoration extends StatelessWidget {
  const BackgroundDecoration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              color: kLightBlue,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(200),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              color: kMediumBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(150),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.25,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: kLightPink,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(200),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.15,
            decoration: const BoxDecoration(
              color: kLightPink,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(100),
              ),
            ),
          ),
        ),
      ],
    );
  }
}