import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:call_queue_pizza/Tabs/setting-main.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode _focusNode = FocusNode();

  final TextEditingController _controller = TextEditingController();
  int? sizesqueue;

  String displayNumber = '000';

  Color selectedBackgroundColor = Colors.black;
  Color selectedTextColor = Colors.white;
  Color selectedTextBlinkColor = Colors.yellow;

  bool LogoSlide = false;
  String? PositionLogoSlide;

  List<File> logoList = [];

  void _handleSubmitted(String value) async {
    if (value == '/1234/') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingMainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double baseFontSize = screenSize.height * 0.05;
    final double fontSize = baseFontSize * (sizesqueue ?? 1.0);

    bool ImageSlide = false;
    String? PositionImageSlide;

    return GestureDetector(
      onTap: () {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      },
      child: Scaffold(
        backgroundColor: selectedBackgroundColor,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.all(5.0), // Add padding for spacing
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Opacity(
                              opacity: 1,
                              child: TextField(
                                controller: _controller,
                                keyboardType: TextInputType.text,
                                focusNode: _focusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Enter number',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: _handleSubmitted,
                              ),
                            ),
                            if (LogoSlide)
                              SizedBox(
                                height: screenSize.height * 0.3,
                                child: Center(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: logoList.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.file(
                                          logoList[index],
                                          fit: BoxFit.fitWidth,
                                          alignment: Alignment.center,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: selectedBackgroundColor,
                      child: Center(
                        child: Text(
                          displayNumber,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: selectedTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSideContainer(fontSize),
          ],
        ),
      ),
    );
  }

  Widget _buildSideContainer(double fontSize) {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.red,
        child: Center(
          child: Text(
            displayNumber,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: selectedTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
