import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive/hive.dart';

class TabQueueScreen extends StatefulWidget {
  const TabQueueScreen({super.key});

  @override
  State<TabQueueScreen> createState() => _TabQueueScreenState();
}

class _TabQueueScreenState extends State<TabQueueScreen> {
  final _queueNumberController = TextEditingController();
  final _fontSizeController = TextEditingController();
  final _speedImageController = TextEditingController();
  final _color1Controller = TextEditingController();
  final _color2Controller = TextEditingController();
  final _color3Controller = TextEditingController();

  Color? _color1;
  Color? _color2;
  Color? _color3;

  late Box box;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('settingsBox');
    _loadSettings();
  }

  Future<void> _clearSettings() async {
    await box.clear();
    setState(() {
      _queueNumberController.clear();
      _fontSizeController.clear();
      _speedImageController.clear();
      _color1Controller.clear();
      _color2Controller.clear();
      _color3Controller.clear();
      _color1 = null;
      _color2 = null;
      _color3 = null;
    });

    _saveSettings();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings cleared! (ลบการตั้งค่าทั้งหมด)')),
    );
  }

  Future<void> _loadSettings() async {
    final queueNumber = box.get('queueNumber', defaultValue: '3');
    final fontSize = box.get('fontSize', defaultValue: '250.0').toString();
    final speedimage = box.get('speedImage', defaultValue: '5').toString();
    final color1 = box.get('color1', defaultValue: 'FFE49723');
    final color2 = box.get('color2', defaultValue: '000000');
    final color3 = box.get('color3', defaultValue: 'FFFFFF');

    setState(() {
      _queueNumberController.text = queueNumber;
      _fontSizeController.text = fontSize;
      _speedImageController.text = speedimage;
      _color1Controller.text = color1;
      _color2Controller.text = color2;
      _color3Controller.text = color3;
      _color1 = _getColorFromHex(color1);
      _color2 = _getColorFromHex(color2);
      _color3 = _getColorFromHex(color3);
    });
  }

  @override
  void dispose() {
    _queueNumberController.dispose();
    _fontSizeController.dispose();
    _speedImageController.dispose();
    _color1Controller.dispose();
    _color2Controller.dispose();
    _color3Controller.dispose();
    super.dispose();
  }

  Color? _getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return null;
    }
  }

  void _saveSettings() {
    final queueNumber = _queueNumberController.text.isNotEmpty
        ? _queueNumberController.text
        : '3';
    final fontSize = double.tryParse(_fontSizeController.text) ?? 14.0;
    final speedImage = double.tryParse(_speedImageController.text) ?? 10;
    final color1 =
        _color1Controller.text.isNotEmpty ? _color1Controller.text : 'FFE49723';
    final color2 =
        _color2Controller.text.isNotEmpty ? _color2Controller.text : '000000';
    final color3 =
        _color3Controller.text.isNotEmpty ? _color3Controller.text : 'FFFFFF';

    box.put('queueNumber', queueNumber);
    box.put('fontSize', fontSize);
    box.put('speedImage', speedImage);
    box.put('color1', color1);
    box.put('color2', color2);
    box.put('color3', color3);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Settings saved! (บันทึกเรียบร้อยแล้วครับ)')),
    );
  }

  void _onColor1Changed(String value) {
    setState(() {
      _color1 = _getColorFromHex(value);
    });
  }

  void _onColor2Changed(String value) {
    setState(() {
      _color2 = _getColorFromHex(value);
    });
  }

  void _onColor3Changed(String value) {
    setState(() {
      _color3 = _getColorFromHex(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: _queueNumberController,
                decoration: const InputDecoration(
                  labelText: 'Queue Number Length (จำนวนหลักคิว)',
                  border: OutlineInputBorder(),
                  hintText:
                      'Queue Number Length (จำนวนหลักคิว)', // ข้อความ hint
                  hintStyle: TextStyle(
                    fontSize: 20.0, // ปรับขนาดตัวอักษรของ hint
                    color: Colors.grey, // เปลี่ยนสีของ hint (ถ้าต้องการ)
                  ),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 20.0, // ปรับขนาดตัวอักษรของข้อมูลที่พิมพ์
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[1-3]')),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fontSizeController,
                decoration: const InputDecoration(
                  labelText: 'Font Size (ขนาดเลขคิว)',
                  border: OutlineInputBorder(),
                  hintText: 'Font Size (ขนาดเลขคิว)', // ข้อความ hint
                  hintStyle: TextStyle(
                    fontSize: 20.0, // ปรับขนาดตัวอักษรของ hint
                    color: Colors.grey, // เปลี่ยนสีของ hint (ถ้าต้องการ)
                  ),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 20.0, // ปรับขนาดตัวอักษรของข้อมูลที่พิมพ์
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: screenSize.width,
                child: Column(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _pickColor(
                                    context, 1); // Function to pick color
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _color1 ??
                                      Colors
                                          .transparent, // Use selected color or transparent if not set
                                  border: Border.all(
                                    color: _color1 != null
                                        ? Colors.transparent
                                        : Colors
                                            .grey, // Grey border if no color selected
                                    width: 2,
                                  ),
                                ),
                                child: _color1 != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _color1, // Use selected color
                                        ),
                                      )
                                    : const Icon(
                                        Icons.color_lens,
                                        color:
                                            Colors.black, // Default icon color
                                      ),
                              ),
                            ),
                            if (_color1 != null) const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _color1Controller,
                                style: const TextStyle(
                                  fontSize:
                                      20.0, // ปรับขนาดตัวอักษรของข้อมูลที่พิมพ์
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  labelText:
                                      'Enter Color Coder Started (สีเริ่มต้น)',
                                  border: OutlineInputBorder(),
                                  hintText:
                                      'Enter Color Coder Started (สีเริ่มต้น)', // ข้อความ hint
                                  hintStyle: TextStyle(
                                    fontSize: 20.0, // ปรับขนาดตัวอักษรของ hint
                                    color: Colors.grey, // เปลี่ยนสีของ hint
                                  ),
                                ),
                                onChanged: _onColor1Changed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _pickColor(
                                    context, 2); // Function to pick color
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _color2 ??
                                      Colors
                                          .transparent, // Use selected color or transparent if not set
                                  border: Border.all(
                                    color: _color2 != null
                                        ? Colors.transparent
                                        : Colors
                                            .grey, // Grey border if no color selected
                                    width: 2,
                                  ),
                                ),
                                child: _color2 != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _color2, // Use selected color
                                        ),
                                      )
                                    : const Icon(
                                        Icons.color_lens,
                                        color:
                                            Colors.black, // Default icon color
                                      ),
                              ),
                            ),
                            if (_color2 != null) const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _color2Controller,
                                style: const TextStyle(
                                  fontSize:
                                      20.0, // ปรับขนาดตัวอักษรของข้อมูลที่พิมพ์
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  labelText:
                                      'Enter Color Coder Blink (สีที่จะกระพริบ)',
                                  border: OutlineInputBorder(),
                                  hintText:
                                      'Enter Color Coder Blink (สีที่จะกระพริบ)', // ข้อความ hint
                                  hintStyle: TextStyle(
                                    fontSize: 20.0, // ปรับขนาดตัวอักษรของ hint
                                    color: Colors.grey, // เปลี่ยนสีของ hint
                                  ),
                                ),
                                onChanged: _onColor2Changed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _pickColor(
                                    context, 3); // Function to pick color
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _color3 ??
                                      Colors
                                          .transparent, // Use selected color or transparent if not set
                                  border: Border.all(
                                    color: _color3 != null
                                        ? Colors.transparent
                                        : Colors
                                            .grey, // Grey border if no color selected
                                    width: 2,
                                  ),
                                ),
                                child: _color3 != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _color3, // Use selected color
                                        ),
                                      )
                                    : const Icon(
                                        Icons.color_lens,
                                        color:
                                            Colors.black, // Default icon color
                                      ),
                              ),
                            ),
                            if (_color3 != null) const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _color3Controller,
                                style: const TextStyle(
                                  fontSize:
                                      20.0, // ปรับขนาดตัวอักษรของข้อมูลที่พิมพ์
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  labelText:
                                      'Enter Color Backgrounds (สีพื้นหลัง)',
                                  border: OutlineInputBorder(),
                                  hintText:
                                      'Enter Color Backgrounds (สีพื้นหลัง)', // ข้อความ hint
                                  hintStyle: TextStyle(
                                    fontSize: 20.0, // ปรับขนาดตัวอักษรของ hint
                                    color: Colors.grey, // เปลี่ยนสีของ hint
                                  ),
                                ),
                                onChanged: _onColor3Changed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _speedImageController,
                decoration: const InputDecoration(
                  labelText:
                      'Set the speed for scrolling the image. (กำหนดความเร็วในการเลื่อนรูปภาพ)',
                  border: OutlineInputBorder(),
                  hintText:
                      'Set the speed for scrolling the image. (กำหนดความเร็วในการเลื่อนรูปภาพ)', // ข้อความ hint
                  hintStyle: TextStyle(
                    fontSize: 20.0, // ปรับขนาดตัวอักษรของ hint
                    color: Colors.grey, // เปลี่ยนสีของ hint (ถ้าต้องการ)
                  ),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 20.0, // ปรับขนาดตัวอักษรของข้อมูลที่พิมพ์
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue, // สีพื้นหลังของปุ่ม
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 32.0,
                        ), // ขนาดปุ่ม
                        minimumSize: const Size(
                            double.infinity, 60), // ทำให้ปุ่มมีขนาดกว้างเต็มที่
                      ),
                      child: const Text(
                        'Save Settings\n(บันทึกการตั้งค่าหน้านี้)', // \n ทำให้ข้อความไปอยู่บรรทัดถัดไป
                        textAlign:
                            TextAlign.center, // จัดตำแหน่งข้อความให้อยู่กลาง
                        style: TextStyle(
                          fontSize: 20.0, // ขนาดตัวอักษรของข้อความบนปุ่ม
                          fontWeight: FontWeight.bold, // น้ำหนักตัวอักษร
                          inherit: false, // ไม่ให้สืบทอดจาก Theme
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(width: 16), // ให้มีระยะห่างระหว่างปุ่ม
                  // Expanded(
                  //   child: ElevatedButton(
                  //     onPressed: _clearSettings,
                  //     style: ElevatedButton.styleFrom(
                  //       foregroundColor: Colors.white,
                  //       backgroundColor: const Color.fromARGB(
                  //           255, 243, 33, 33), // สีพื้นหลังของปุ่ม
                  //       padding: const EdgeInsets.symmetric(
                  //         vertical: 16.0,
                  //         horizontal: 32.0,
                  //       ), // ขนาดปุ่ม
                  //       minimumSize: const Size(
                  //           double.infinity, 60), // ทำให้ปุ่มมีขนาดกว้างเต็มที่
                  //     ),
                  //     child: const Text(
                  //       'Clear Settings\n(ล้าางค่าตั้งค่าหน้านี้)', // \n ทำให้ข้อความไปอยู่บรรทัดถัดไป
                  //       textAlign:
                  //           TextAlign.center, // จัดตำแหน่งข้อความให้อยู่กลาง
                  //       style: TextStyle(
                  //         fontSize: 40.0, // ขนาดตัวอักษรของข้อความบนปุ่ม
                  //         fontWeight: FontWeight.bold, // น้ำหนักตัวอักษร
                  //         inherit: false, // ไม่ให้สืบทอดจาก Theme
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _pickColor(BuildContext context, int colorIndex) {
    Color initialColor = colorIndex == 1
        ? _color1 ?? Colors.transparent
        : colorIndex == 2
            ? _color2 ?? Colors.transparent
            : _color3 ?? Colors.transparent;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: (Color color) {
                setState(() {
                  if (colorIndex == 1) {
                    _color1 = color;
                    _color1Controller.text =
                        '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}'; // Update text field
                  } else if (colorIndex == 2) {
                    _color2 = color;
                    _color2Controller.text =
                        '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}'; // Update text field
                  } else {
                    _color3 = color;
                    _color3Controller.text =
                        '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}'; // Update text field
                  }
                });
              },
              // Display color names
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
