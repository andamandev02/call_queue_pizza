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
    box = await Hive.openBox('orderSettingsBox');
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final color = box.get('color', defaultValue: '');
    final background = box.get('background', defaultValue: '');
    final text = box.get('text', defaultValue: '');
    final fontSize = box.get('fontSizeOrder', defaultValue: '14.0').toString();
    final radius = box.get('radius', defaultValue: '0').toString();

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
    final color = _colorController.text;
    final background = _backgroundController.text;
    final text = _textController.text;
    final fontSize = double.tryParse(_fontSizeController.text) ?? 14.0;
    final radius = double.tryParse(_radiusController.text) ?? 0.0;

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
                    decoration: const InputDecoration(
                      labelText: 'Enter Color Code Text (รหัสสีข้อความ)',
                      border: OutlineInputBorder(),
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
                    decoration: const InputDecoration(
                      labelText:
                          'Enter Color Code Backgrounds (รหัสสีพื้นหลัง)',
                      border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Enter Text (ข้อความ)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fontSizeController,
              decoration: const InputDecoration(
                labelText: 'Font Size [e.g., 14] (ขนาดข้อความ เริ่มต้นที่ 14)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _radiusController,
              decoration: const InputDecoration(
                labelText: 'Enter Radius (รัศมี)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
