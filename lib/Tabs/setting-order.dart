import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TabOrderScreen extends StatefulWidget {
  const TabOrderScreen({super.key});

  @override
  State<TabOrderScreen> createState() => _TabOrderScreenState();
}

class _TabOrderScreenState extends State<TabOrderScreen> {
  final _colorController = TextEditingController();
  final _backgroundController = TextEditingController();
  final _textController = TextEditingController();
  final _fontSizeController = TextEditingController();
  final _radiusController = TextEditingController();

  Color? _displayColor;
  Color? _backgroundColor;
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
      _colorController.clear();
      _backgroundController.clear();
      _textController.clear();
      _fontSizeController.clear();
      _radiusController.clear();
      _displayColor = null;
      _backgroundColor = null;
    });

    _saveSettings();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings cleared! (ลบการตั้งค่าทั้งหมด)')),
    );
  }

  Future<void> _loadSettings() async {
    final color = box.get('color', defaultValue: 'FFFFFF');
    final background = box.get('background', defaultValue: 'FFE49723');
    final text = box.get('text', defaultValue: 'Order Number');
    final fontSize = box.get('fontSizeOrder', defaultValue: '40').toString();
    final radius = box.get('radius', defaultValue: '50').toString();

    setState(() {
      _colorController.text = color;
      _backgroundController.text = background;
      _textController.text = text;
      _fontSizeController.text = fontSize;
      _radiusController.text = radius;
      _displayColor = _getColorFromHex(color);
      _backgroundColor = _getColorFromHex(background);
    });
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
    final color =
        _colorController.text.isNotEmpty ? _colorController.text : '000000';
    final background = _backgroundController.text.isNotEmpty
        ? _backgroundController.text
        : 'FFFFFF';
    final text = _textController.text.isNotEmpty
        ? _textController.text
        : 'ไม่ได้ตั้งค่า';
    final fontSize = double.tryParse(_fontSizeController.text) ?? 0.07;
    final radius = double.tryParse(_radiusController.text) ?? 50.0;

    box.put('color', color);
    box.put('background', background);
    box.put('text', text);
    box.put('fontSizeOrder', fontSize);
    box.put('radius', radius);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Settings saved! (บันทึกเรียบร้อยแล้วครับ)')),
    );

    setState(() {
      _displayColor = _getColorFromHex(color);
      _backgroundColor = _getColorFromHex(background);
    });
  }

  @override
  void dispose() {
    _colorController.dispose();
    _textController.dispose();
    _fontSizeController.dispose();
    _backgroundController.dispose();
    _radiusController.dispose(); // ปล่อยตัวควบคุมรัศมี
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_displayColor != null)
                    Container(
                      height: 50,
                      width: 50,
                      color: _displayColor,
                    ),
                  if (_displayColor != null) const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _colorController,
                      style: const TextStyle(
                        fontSize: 20.0, // ปรับขนาดตัวอักษรของข้อมูลที่พิมพ์
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Enter Color Code Text (รหัสสีข้อความ)',
                        border: OutlineInputBorder(),
                        hintText:
                            'Enter Color Code Text (รหัสสีข้อความ)', // ข้อความ hint
                        hintStyle: TextStyle(
                          fontSize: 20.0, // ปรับขนาดตัวอักษรของ hint
                          color: Colors.grey, // เปลี่ยนสีของ hint (ถ้าต้องการ)
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _displayColor = _getColorFromHex(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_backgroundColor != null)
                    Container(
                      height: 50,
                      width: 50,
                      color: _backgroundColor,
                    ),
                  if (_backgroundColor != null) const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _backgroundController,
                      style: const TextStyle(
                        fontSize: 20.0, // ปรับขนาดตัวอักษรของข้อมูลที่พิมพ์
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        labelText:
                            'Enter Color Code Backgrounds (รหัสสีพื้นหลัง)',
                        border: OutlineInputBorder(),
                        hintText:
                            'Enter Color Code Backgrounds (รหัสสีพื้นหลัง)', // ข้อความ hint
                        hintStyle: TextStyle(
                          fontSize: 20.0, // ปรับขนาดตัวอักษรของ hint
                          color: Colors.grey, // เปลี่ยนสีของ hint (ถ้าต้องการ)
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _backgroundColor = _getColorFromHex(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                style: const TextStyle(
                  fontSize: 20.0, // ปรับขนาดตัวอักษรของข้อมูลที่พิมพ์
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: 'Enter Text (ข้อความ)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter Text (ข้อความ)', // ข้อความ hint
                  hintStyle: TextStyle(
                    fontSize: 20.0, // ปรับขนาดตัวอักษรของ hint
                    color: Colors.grey, // เปลี่ยนสีของ hint (ถ้าต้องการ)
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fontSizeController,
                style: const TextStyle(
                  fontSize: 20.0, // ปรับขนาดตัวอักษรของข้อมูลที่พิมพ์
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText:
                      'Font Size [e.g., 0.07] (ขนาดข้อความ เริ่มต้นที่ 0.07)',
                  border: OutlineInputBorder(),
                  hintText:
                      'Font Size [e.g., 0.07] (ขนาดข้อความ เริ่มต้นที่ 0.07)', // ข้อความ hint
                  hintStyle: TextStyle(
                    fontSize: 20.0, // ปรับขนาดตัวอักษรของ hint
                    color: Colors.grey, // เปลี่ยนสีของ hint (ถ้าต้องการ)
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _radiusController,
                style: const TextStyle(
                  fontSize: 20.0, // ปรับขนาดตัวอักษรของข้อมูลที่พิมพ์
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: 'Enter Radius (รัศมี)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter Radius (รัศมี)', // ข้อความ hint
                  hintStyle: TextStyle(
                    fontSize: 20.0, // ปรับขนาดตัวอักษรของ hint
                    color: Colors.grey, // เปลี่ยนสีของ hint (ถ้าต้องการ)
                  ),
                ),
                keyboardType: TextInputType.number,
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
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
