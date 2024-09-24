import 'dart:async';
import 'dart:io';
import 'package:call_queue_pizza/Tabs/setting-main.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

  double? Sizefont;
  double? SizefontOrder;
  double? SizefontRadius;

  String displayNumber = '000';
  String TextOrder = '';

  Color selectedBackgroundColor = Colors.black;
  Color selectedTextColor = Colors.white;
  Color selectedTextBlinkColor = Colors.yellow;

  Color selectedBackgroundOrderColor = Colors.black;
  Color selectedTextOrderColor = Colors.white;

  bool LogoSlide = false;
  String? PositionLogoSlide;

  List<File> logoList = [];

  late Box box;

  String? errorLoading;

  @override
  void initState() {
    super.initState();
    _requestExternalStoragePermission();
    _openBox();
  }

  Future<void> _requestExternalStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
    } else {
      setState(() {
        errorLoading = 'Permission denied for storage';
      });
    }
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('settingsBox');
    await _loadSettings();
    // เพิ่ม Listener หลังจากที่เปิดกล่องเสร็จ
    box.listenable().addListener(() {
      _loadSettings(); // เรียกใช้เพื่ออัปเดตข้อมูล
    });
  }

  Future<void> _loadSettings() async {
    // /////////////////////////////  queue ////////////////////////
    final queueNumber = box.get('queueNumber', defaultValue: '000').toString();
    final fontSize = box.get('fontSize', defaultValue: 14.0);
    // สีข้อความ
    final color1 = box.get('color1', defaultValue: '');
    // สีที่จะกระพริบ
    final color2 = box.get('color2', defaultValue: '');
    // สีพื้นหลัง
    final color3 = box.get('color3', defaultValue: '');
    // /////////////////////////////  queue ////////////////////////


    // /////////////////////////////  ORDER ////////////////////////
    final color = box.get('color', defaultValue: '');
    final background = box.get('background', defaultValue: '');
    final text = box.get('text', defaultValue: '');
    final fontSizeOrder = box.get('fontSizeOrder', defaultValue: '14.0');
    final radius = box.get('radius', defaultValue: '0');
    // /////////////////////////////  ORDER ////////////////////////


    // /////////////////////////////  usb ////////////////////////
    final usb = box.get('usbPath', defaultValue: '').toString();
    print(usb);

    // /////////////////////////////  usb ////////////////////////


    setState(() {


    // /////////////////////////////  queue ////////////////////////
      // ตรวจสอบให้แน่ใจว่า queueNumber เป็นเลขที่ถูกต้อง
      int numberLength = int.tryParse(queueNumber) ?? 0; // แปลงเป็น int
      displayNumber = '0' * numberLength;
      Sizefont = fontSize;
      // แปลงสีข้อความจาก String เป็น Color
      selectedTextColor =
          color1.isNotEmpty ? _getColorFromHex(color1) : Colors.black;
      // แปลงสีที่จะกระพริบจาก String เป็น Color
      selectedTextBlinkColor =
          color2.isNotEmpty ? _getColorFromHex(color2) : Colors.black;
      // แปลงสีพื้นหลังจาก String เป็น Color
      selectedBackgroundColor =
          color3.isNotEmpty ? _getColorFromHex(color3) : Colors.black;
    // /////////////////////////////  queue ////////////////////////


    // /////////////////////////////  ORDER ////////////////////////
      TextOrder = text;
      SizefontOrder = fontSizeOrder;
      SizefontRadius = radius;
      // แปลงสีข้อความจาก String เป็น Color
      selectedTextOrderColor =
          color.isNotEmpty ? _getColorFromHex(color) : Colors.black;
      selectedBackgroundOrderColor =
          background.isNotEmpty ? _getColorFromHex(background) : Colors.black;
    // /////////////////////////////  ORDER ////////////////////////


    // /////////////////////////////  usb ////////////////////////
      // loadLogoFromUSB(usb);
    // /////////////////////////////  usb ////////////////////////


    });
  }


  Future<void> loadLogoFromUSB(String usb) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await _requestExternalStoragePermission();
    }
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      throw 'External storage directory not found';
    }
    String usbPath = usb;
    if (usbPath == null) {
      throw 'USB path is null';
    }
    Directory usbDir = Directory(usbPath);
    if (!usbDir.existsSync()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          const duration = Duration(seconds: 2);
          Timer(duration, () {
            Navigator.of(context).pop();
          });
          return AlertDialog(
            title: Text(
              'USB directory does not exist : $usbPath',
              style: const TextStyle(fontSize: 50),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
      throw 'USB directory does not exist';
    }

    List<FileSystemEntity> files = usbDir.listSync();

    if (files.isEmpty) {
      throw 'No files found in USB directory';
    }
    List<File> logoFiles = files.whereType<File>().toList();
    if (logoFiles.isEmpty) {
      throw 'No image files found in USB directory';
    }
    setState(() {
      logoList = logoFiles;
    });
  }

  // ฟังก์ชันแปลงรหัสสี HEX เป็น Color
  Color _getColorFromHex(String hexColor) {
    final buffer = StringBuffer();
    if (hexColor.length == 6 || hexColor.length == 7) {
      buffer.write('FF'); // เพิ่มค่า alpha ให้เป็น 255 (ไม่โปร่งใส)
    }
    buffer.write(hexColor.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

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
    final double baseFontSize = screenSize.height * 0.02;
    final double fontSize = baseFontSize * (Sizefont ?? 1.0);
    final double fontSizeOrder = screenSize.height * (SizefontOrder ?? 0.1);

    return GestureDetector(
      onTap: () {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      },
      child: Scaffold(
        backgroundColor: selectedBackgroundColor,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Container(
                    padding: EdgeInsets.all(1.0), // ขนาดของพื้นที่ภายใน
                    decoration: BoxDecoration(
                      color: selectedBackgroundOrderColor, // สีพื้นหลังของกล่อง
                      border: Border.all(
                          color: selectedBackgroundOrderColor , width: 1), // ขอบสีส้ม
                      borderRadius: BorderRadius.circular(SizefontRadius ?? 0.0), // ขอบโค้ง
                    ),
                    child: Text(
                      TextOrder,
                      style:  TextStyle(
                        fontSize: fontSizeOrder, // ขนาดตัวอักษร
                        fontWeight: FontWeight.bold, // น้ำหนักตัวอักษร
                        color: selectedTextOrderColor, // สีตัวอักษร
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      displayNumber,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: selectedTextColor,
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
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Center(
          child: Text(
            '',
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
