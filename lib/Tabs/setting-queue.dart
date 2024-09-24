import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TabQueueScreen extends StatefulWidget {
  const TabQueueScreen({super.key});

  @override
  State<TabQueueScreen> createState() => _TabQueueScreenState();
}

class _TabQueueScreenState extends State<TabQueueScreen> {
  final _queueNumberController = TextEditingController();
  final _fontSizeController = TextEditingController();
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

  Future<void> _loadSettings() async {
    final queueNumber = box.get('queueNumber', defaultValue: '');
    final fontSize = box.get('fontSize', defaultValue: '14.0').toString();
    final color1 = box.get('color1', defaultValue: '');
    final color2 = box.get('color2', defaultValue: '');
    final color3 = box.get('color3', defaultValue: '');

    setState(() {
      _queueNumberController.text = queueNumber;
      _fontSizeController.text = fontSize;
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
    final queueNumber = _queueNumberController.text;
    final fontSize = double.tryParse(_fontSizeController.text) ?? 14.0;
    final color1 = _color1Controller.text;
    final color2 = _color2Controller.text;
    final color3 = _color3Controller.text;

    box.put('queueNumber', queueNumber);
    box.put('fontSize', fontSize);
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
    return Padding(
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
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fontSizeController,
              decoration: const InputDecoration(
                labelText: 'Font Size (ขนาดเลขคิว)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  children: [
                    if (_color1 != null)
                      Container(
                        height: 50,
                        width: 50,
                        color: _color1,
                        margin: const EdgeInsets.only(top: 8),
                      ),
                    if (_color2 != null) const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _color1Controller,
                        decoration: const InputDecoration(
                          labelText: 'Enter Color Coder Started (สีเริ่มต้น)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _onColor1Changed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (_color2 != null)
                      Container(
                        height: 50,
                        width: 50,
                        color: _color2,
                        margin: const EdgeInsets.only(top: 8),
                      ),
                    if (_color2 != null) const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _color2Controller,
                        decoration: const InputDecoration(
                          labelText: 'Enter Color Coder Blink (สีที่จะกระพริบ)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _onColor2Changed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (_color3 != null)
                      Container(
                        height: 50,
                        width: 50,
                        color: _color3,
                        margin: const EdgeInsets.only(top: 8),
                      ),
                    if (_color3 != null) const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _color3Controller,
                        decoration: const InputDecoration(
                          labelText: 'Enter Color Backgrounds (สีพื้นหลัง)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _onColor3Changed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings (บันทึกการตั้งค่าหน้านี้)'),
            ),
          ],
        ),
      ),
    );
  }
}
