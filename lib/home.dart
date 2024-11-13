import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:call_queue_pizza/Tabs/setting-main.dart';
import 'package:call_queue_pizza/Tabs/setting-queue.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  FocusNode _focusNode = FocusNode();

  final TextEditingController _controller = TextEditingController();

  double? Sizefont = 20.0;
  double? SizefontOrder = 0.07;
  double? SizefontRadius = 50;
  double? SpeedImage = 10;

  String displayNumber = '000';
  String TextOrder = 'ตั้งค่าชื่อ';

  Color selectedBackgroundColor = const Color.fromARGB(255, 255, 255, 255);
  Color selectedTextColor = const Color.fromARGB(255, 228, 151, 35);
  Color selectedTextBlinkColor = Colors.yellow;

  Color selectedBackgroundOrderColor = const Color.fromARGB(255, 228, 151, 35);
  Color selectedTextOrderColor = Colors.white;

  bool LogoSlide = false;
  String? PositionLogoSlide;

  List<File> logoList = [];
  List<File> imageList = [];
  List<bool> isVideoList = [];

  late Box box;
  late Box boxmode;

  String? errorLoading;

  bool _isPlaying = false;
  bool _isFieldEnabled = true;

  final PageController _pageController = PageController();
  final Duration _changeImageDuration = const Duration(seconds: 5);
  Map<int, bool> _videoStatuses = {};

  Timer? _timer;
  Color _textColor = const Color.fromARGB(255, 242, 255, 0);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _requestExternalStoragePermission();
    _openBox();
    startTimer();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
    stopTimer();
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void startTimer() {
    Timer.periodic(_changeImageDuration, (Timer timer) {
      if (_pageController.hasClients) {
        int currentPage = (_pageController.page?.toInt() ?? 0);
        int nextPage = currentPage + 1;
        if (nextPage >= imageList.length) {
          nextPage = 0;
        }

        if (isVideoList[currentPage]) {
          if (_videoStatuses[currentPage] == true) {
            _pageController.animateToPage(
              nextPage,
              duration: Duration(
                milliseconds: (SpeedImage != null
                    ? (SpeedImage! * 1000).toInt()
                    : 1000), // แปลงเป็น milliseconds
              ),
              curve: Curves.easeInOut,
            );
          }
        } else {
          // หากเป็นภาพ ให้เปลี่ยนหน้าไปปกติ
          _pageController.animateToPage(
            nextPage,
            duration: Duration(
              milliseconds: (SpeedImage != null
                  ? (SpeedImage! * 1000).toInt()
                  : 1000), // แปลงเป็น milliseconds
            ),
            curve: Curves.easeInOut,
          );
        }
      }
    });
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
    await Hive.initFlutter();
    box = await Hive.openBox('settingsBox');
    boxmode = await Hive.openBox('ModeSounds');
    await _loadSettings();
    box.listenable().addListener(() {
      _loadSettings();
    });
    boxmode.listenable().addListener(() {
      _loadSettings();
    });
    setState(() {});
  }

  Future<void> _loadSettings() async {
    final queueNumber = box.get('queueNumber', defaultValue: '000').toString();
    final fontSize = box.get('fontSize', defaultValue: '250.0');
    final speedImagea = box.get('speedImage', defaultValue: 10);
    final color1 = box.get('color1', defaultValue: 'FFE49723');
    final color2 = box.get('color2', defaultValue: '000000');
    final color3 = box.get('color3', defaultValue: 'FFFFFF');

    // Load order settings
    final color = box.get('color', defaultValue: '');
    final background = box.get('background', defaultValue: '');
    final text = box.get('text', defaultValue: '');
    final fontSizeOrder = box.get('fontSizeOrder', defaultValue: '0.07');
    final radius = box.get('radius', defaultValue: '50');

    // Load USB settings
    final usb = box.get('usbPath', defaultValue: '').toString();

    setState(() {
      // int numberLength = int.tryParse(queueNumber) ?? 0;
      // displayNumber = '0' * numberLength;
      Sizefont = fontSize;
      selectedTextColor = color1.isNotEmpty
          ? _getColorFromHex(color1)
          : const Color.fromARGB(255, 228, 151, 35);
      selectedTextBlinkColor = color2.isNotEmpty
          ? _getColorFromHex(color2)
          : const Color.fromARGB(255, 255, 238, 0);
      selectedBackgroundColor = color3.isNotEmpty
          ? _getColorFromHex(color3)
          : const Color.fromARGB(255, 255, 255, 255);

      // Order settings
      TextOrder = text;
      SizefontOrder = fontSizeOrder;
      SpeedImage = speedImagea;
      SizefontRadius = radius;
      selectedTextOrderColor = color.isNotEmpty
          ? _getColorFromHex(color)
          : const Color.fromARGB(255, 255, 255, 255);
      selectedBackgroundOrderColor = (background.isNotEmpty
          ? _getColorFromHex(background)
          : const Color.fromARGB(255, 228, 151, 35));
    });

    // Load logo and images from USB
    await loadImagesFromUSB();
    await loadLogoFromUSB();
  }

  Future<void> loadLogoFromUSB() async {
    final usb = box.get('usbPath', defaultValue: '').toString();

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await _requestExternalStoragePermission();
    }

    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      throw 'External storage directory not found';
    }

    // USB directory path
    String usbPath = p.join(usb, 'logo');
    // String usbPath = '$usb/logo';
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
              'USB directory does not exist: $usbPath',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
      throw 'USB directory does not exist';
    }

    // Load files from USB directory
    List<FileSystemEntity> files = usbDir.listSync();
    if (files.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          const duration = Duration(seconds: 2);
          Timer(duration, () {
            Navigator.of(context).pop();
          });
          return AlertDialog(
            title: Text(
              'No files found in USB directory',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
      throw 'No files found in USB directory';
    }

    List<File> logoFiles = files.whereType<File>().toList();
    if (logoFiles.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          const duration = Duration(seconds: 2);
          Timer(duration, () {
            Navigator.of(context).pop();
          });
          return AlertDialog(
            title: Text(
              'No image files found in USB directory',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
      throw 'No image files found in USB directory';
    }

    setState(() {
      logoList = logoFiles;
    });
  }

  Future<void> loadImagesFromUSB() async {
    final usb = box.get('usbPath', defaultValue: '').toString();

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      throw 'External storage directory not found';
    }
    // USB directory path
    String usbPath = p.join(usb, 'images');
    Directory usbDir = Directory(usbPath);
    if (usbPath.isEmpty) {
      throw 'USB path is null';
    }
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

    List<File> imageFiles = files.whereType<File>().toList();
    if (imageFiles.isEmpty) {
      throw 'No image files found in USB directory';
    }

    _detectFileTypes(imageFiles);
    imageList = imageFiles;
    setState(() {
      imageList = imageFiles;
    });
  }

  void _detectFileTypes(List<File> files) {
    isVideoList = files.map((file) {
      return file.path.endsWith('.mp4') || file.path.endsWith('.avi');
    }).toList();
  }

  // ฟังก์ชันแปลงรหัสสี HEX เป็น Color
  Color _getColorFromHex(String hexColor) {
    final buffer = StringBuffer();
    if (hexColor.length == 6 || hexColor.length == 7) {
      buffer.write('FF');
    }
    buffer.write(hexColor.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  void _handleSubmitted(String value) async {
    if (_isPlaying) {
      return;
    }
    setState(() {
      _isFieldEnabled = false;
    });
    if (value == '*') {
      _handleMultiply();
    } else if (value == '/1234/') {
      _controller.clear();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingMainScreen()),
      );
      _handleInvalidCharacter();
    } else if (int.tryParse(value) != null) {
      _handleNumericValue(value);
    } else if (value.startsWith('***')) {
      _handleModeChange(value);
      setState(() {
        _isFieldEnabled = true;
      });
    } else if (RegExp(r'[^\d+.*/]').hasMatch(value)) {
      _handleInvalidCharacter();
      setState(() {
        _isFieldEnabled = true;
      });
    } else {
      _handleInvalidCharacter();
    }
  }

  void _handleModeChange(String value) async {
    String numberPart = value.substring(3);
    if (numberPart.isNotEmpty && int.tryParse(numberPart) != null) {
      await _addToHive(numberPart);
      var mode = boxmode!.get('mode');
      _showModeChangeDialog(mode);
    } else {
      _focusNode.requestFocus();
      _controller.clear();
    }
  }

  Future<void> _addToHive(String mode) async {
    await boxmode.put('mode', mode);
    setState(() {});
  }

  void _showModeChangeDialog(String mode) {
    String title, content;
    switch (mode) {
      case '1':
        title = 'MODE 1 : Bell';
        content = '';
        break;
      case '2':
        title = 'MODE 2 : Calling voice - THAI';
        content = '';
        break;
      case '3':
        title = 'MODE 3 : Calling voice - ENGLISH';
        content = '';
        break;
      // case '4':
      //   title = 'MODE 4 : Calling voice - CHINA';
      //   content = '';
      //   break;
      case '4':
        title = 'MODE 4 : Calling voice - THAI & ENGLISH';
        content = '';
        break;
      // case '6':
      //   title = 'MODE 6 : Calling voice - THAI & CHINA';
      //   content = '';
      //   break;
      // case '7':
      //   title = 'MODE 7 : Calling voice - ENGLISH & CHINA';
      //   content = '';
      //   break;
      // case '8':
      //   title = 'MODE 8 : Calling voice - THAI & ENGLISH & CHINA';
      //   content = '';
      //   break;
      default:
        title = 'Bell';
        content = '';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        const duration = Duration(seconds: 2);
        Timer(duration, () {
          Navigator.of(context).pop();
        });
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 50),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
    _focusNode.requestFocus();
    _controller.clear();
  }

  void _handleInvalidCharacter() {
    setState(() {
      _isFieldEnabled = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFieldEnabled) {
        _focusNode.requestFocus();
        _controller.clear();
      }
    });
  }

  void _handleMultiply() {
    setState(() {
      displayNumber = '000';
      _isFieldEnabled = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFieldEnabled) {
        _focusNode.requestFocus();
        _controller.clear();
      }
    });
  }

  void _handleNumericValue(String value) async {
    final queueNumber = box.get('queueNumber', defaultValue: '').toString();
    int numberOfDigits = int.tryParse(queueNumber) ?? 3;
    displayNumber = value.toString().padLeft(numberOfDigits, '0');

    if (displayNumber.length > numberOfDigits) {
      displayNumber = displayNumber.substring(0, numberOfDigits);
    }
    _playSound(displayNumber);
  }

  void _playSound(String value) async {
    try {
      final usb = box.get('usbPath', defaultValue: '').toString();

      var boxmode = await Hive.openBox('ModeSounds');
      var mode = boxmode.values.first;

      final trimmedString = value.toString();
      final numberString = trimmedString.replaceAll(RegExp('^0+'), '');

      Directory? externalDir = await getExternalStorageDirectory();
      String usbPath = p.join(usb, 'sounds');
      Directory usbDir = Directory(usbPath);

      if (await usbDir.exists()) {
        Future<void> _playAudioFile(String path) async {
          try {
            if (await File(path).exists()) {
              await _audioPlayer.play(DeviceFileSource(path));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Audio file not found: $path'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error playing audio file: $e'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }

        _startBlinking();

        // ตรวจสอบโหมดเสียง
        if (mode == '1') {
          await _playAudioFile(p.join(usbPath, 'bell.MP3'));
        } else if (mode == '2') {
          await _playAudioFile(
              p.join(usbPath, 'TH', 'TH- ($numberString).MP3'));
        } else if (mode == '3') {
          await _playAudioFile(
              p.join(usbPath, 'EN', 'EN- ($numberString).MP3'));
          // } else if (mode == '4') {
          //   await _playAudioFile(
          //       p.join(usbPath, 'CN', 'CN- ($numberString).MP3'));
        } else if (mode == '4') {
          await _playAudioFile(
              p.join(usbPath, 'TH', 'TH- ($numberString).MP3'));
          await Future.delayed(const Duration(milliseconds: 2500));
          await _playAudioFile(
              p.join(usbPath, 'EN', 'EN- ($numberString).MP3'));
          // } else if (mode == '6') {
          //   await _playAudioFile(
          //       p.join(usbPath, 'TH', 'TH- ($numberString).MP3'));
          //   await Future.delayed(const Duration(milliseconds: 150));
          //   await _playAudioFile(
          //       p.join(usbPath, 'CN', 'CN- ($numberString).MP3'));
          // } else if (mode == '7') {
          //   await _playAudioFile(
          //       p.join(usbPath, 'EN', 'EN- ($numberString).MP3'));
          //   await Future.delayed(const Duration(milliseconds: 150));
          //   await _playAudioFile(
          //       p.join(usbPath, 'CN', 'CN- ($numberString).MP3'));
          // } else if (mode == '8') {
          //   await _playAudioFile(
          //       p.join(usbPath, 'TH', 'TH- ($numberString).MP3'));
          //   await Future.delayed(const Duration(milliseconds: 150));
          //   await _playAudioFile(
          //       p.join(usbPath, 'EN', 'EN- ($numberString).MP3'));
          //   await Future.delayed(const Duration(milliseconds: 150));
          //   await _playAudioFile(
          //       p.join(usbPath, 'CN', 'CN- ($numberString).MP3'));
        } else {
          await _playAudioFile(p.join(usbPath, 'bell.MP3'));
        }

        // เรียก setState หลังจากการเล่นเสียงและ delay เสร็จสมบูรณ์แล้ว
        setState(() {
          _isFieldEnabled = true;
          _controller.clear();
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusNode.requestFocus();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('USB directory does not exist: $usbPath'),
            duration: const Duration(seconds: 3),
          ),
        );
        // กรณีไม่พบไดเรกทอรี USB ให้เปิดใช้งานฟิลด์ใหม่
        setState(() {
          _isFieldEnabled = true;
          _controller.clear();
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusNode.requestFocus();
        });
      }
      _timer?.cancel();
    } catch (e) {
      // จัดการข้อผิดพลาดทั่วไปที่เกิดขึ้นระหว่างการทำงาน
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          duration: const Duration(seconds: 3),
        ),
      );

      // ทำให้แน่ใจว่า _isFieldEnabled ถูกตั้งค่าเป็น true แม้เกิดข้อผิดพลาด
      setState(() {
        _isFieldEnabled = true;
      });
    }
  }

  void _startBlinking() {
    final color1 = box.get('color1', defaultValue: '');
    final color2 = box.get('color2', defaultValue: '');

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _textColor = _textColor == color1 ? color2 : color1;
      });
    });

    Timer(const Duration(seconds: 3), () {
      _timer?.cancel(); // หยุด Timer
      setState(() {
        _textColor = color1;
      });
    });
  }

  void _checkvalue(String value) async {
    if (_isPlaying) {
      return;
    }
    if (value == '.') {
      setState(() {
        _isFieldEnabled = false;
      });
      if (displayNumber == '000' ||
          displayNumber == '00' ||
          displayNumber == '0') {
        await Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            _isFieldEnabled = true;
            _controller.clear();
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _focusNode.requestFocus();
          });
        });
      } else {
        final queueNumber =
            box.get('queueNumber', defaultValue: '3').toString();
        int numberOfDigits = int.tryParse(queueNumber) ?? 3;
        int currentValue = int.parse(displayNumber);
        displayNumber = currentValue.toString().padLeft(numberOfDigits, '0');
        if (displayNumber.length > numberOfDigits) {
          displayNumber = displayNumber.substring(0, numberOfDigits);
        }
        _playSound(displayNumber);
      }
    } else if (value == '+') {
      setState(() {
        _isFieldEnabled = false;
      });
      _handlePlus();
    }
  }

  void _handlePlus() async {
    final queueNumber = box.get('queueNumber', defaultValue: '3').toString();
    int numberOfDigits = int.tryParse(queueNumber) ?? 3;
    int currentValue = int.parse(displayNumber);
    displayNumber = (currentValue + 1).toString().padLeft(numberOfDigits, '0');
    if (displayNumber.length > numberOfDigits) {
      displayNumber = displayNumber.substring(0, numberOfDigits);
    }
    _playSound(displayNumber);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double baseFontSize = screenSize.height * 0.02;
    final double fontSize = screenSize.height * (Sizefont ?? 0.1);
    final double fontSizeOrder = screenSize.height * (SizefontOrder ?? 0.1);

    return GestureDetector(
      onTap: () {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            // ใช้ ValueListenableBuilder
            Expanded(
              flex: 2,
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box box, child) {
                  final queueNumber =
                      box.get('queueNumber', defaultValue: '000').toString();
                  // final displayNumber = '0' * (int.tryParse(queueNumber) ?? 0);
                  final selectedTextColor = box
                          .get('color1', defaultValue: '')
                          .isNotEmpty
                      ? _getColorFromHex(box.get('color1', defaultValue: ''))
                      : const Color.fromARGB(255, 228, 151, 35);
                  final selectedBackgroundColor = box
                          .get('color3', defaultValue: '')
                          .isNotEmpty
                      ? _getColorFromHex(box.get('color3', defaultValue: ''))
                      : const Color.fromARGB(255, 255, 255, 255);
                  final selectedTextOrderColor =
                      box.get('color', defaultValue: '').isNotEmpty
                          ? _getColorFromHex(box.get('color', defaultValue: ''))
                          : const Color.fromARGB(255, 255, 255, 255);
                  final selectedBackgroundOrderColor =
                      box.get('background', defaultValue: '').isNotEmpty
                          ? _getColorFromHex(
                              box.get('background', defaultValue: ''))
                          : const Color.fromARGB(255, 255, 255, 255);
                  final TextOrder = box.get('text', defaultValue: '').isNotEmpty
                      ? (box.get('text', defaultValue: ''))
                      : 'ตั้งค่าข้อความ';
                  final fontSizeOrder =
                      box.get('fontSizeOrder', defaultValue: '') is double
                          ? box.get('fontSizeOrder', defaultValue: '')
                          : 0.07;
                  final fontSize =
                      box.get('fontSize', defaultValue: '') is double
                          ? box.get('fontSize', defaultValue: '')
                          : 20.0;
                  final SizefontRadius =
                      box.get('radius', defaultValue: '') is double
                          ? box.get('radius', defaultValue: '')
                          : 50.0;

                  return Container(
                    color: selectedBackgroundColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Opacity(
                              opacity: 0,
                              child: TextField(
                                controller: _controller,
                                onChanged: (value) {
                                  _checkvalue(value);
                                },
                                keyboardType: TextInputType.text,
                                focusNode: _focusNode,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintStyle: TextStyle(
                                    fontSize: 1.0,
                                    color: Color.fromARGB(235, 255, 255, 255),
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[\d+-.*/]')),
                                ],
                                onSubmitted: _handleSubmitted,
                                maxLines: 1,
                                enabled: _isFieldEnabled,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: screenSize.width * 0.04),
                              child: Align(
                                alignment: Alignment.center,
                                child: SizedBox(
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
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.only(left: 25.0),
                          padding: EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: selectedBackgroundOrderColor,
                            border: Border.all(
                                color: selectedBackgroundOrderColor, width: 1),
                            borderRadius:
                                BorderRadius.circular(SizefontRadius ?? 0.0),
                          ),
                          child: Text(
                            TextOrder,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width *
                                  (fontSizeOrder / 1000),
                              fontWeight: FontWeight.bold,
                              color: selectedTextOrderColor,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            displayNumber,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width *
                                  (fontSize / 2500),
                              fontWeight: FontWeight.bold,
                              letterSpacing:
                                  displayNumber.contains('1') ? 15.0 : 10.0,
                              color: selectedTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imageList.length,
                itemBuilder: (context, index) {
                  final file = imageList[index];
                  final isVideo = isVideoList[index];

                  if (isVideo) {
                    return Container(
                      color: Colors.black,
                      child: VideoPlayerWidget(
                        file: file,
                        onVideoFinished: (finished) {
                          setState(() {
                            _videoStatuses[index] = finished;
                          });
                        },
                      ),
                    );
                  } else {
                    return Container(
                      color: Colors.black,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Image.file(
                          file,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final File file;
  final ValueChanged<bool> onVideoFinished;

  VideoPlayerWidget({required this.file, required this.onVideoFinished});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..setVolume(0.0)
      ..initialize().then((_) {
        setState(() {}); // อัพเดทหน้าจอเมื่อวิดีโอพร้อมเล่น
        _controller.play(); // เริ่มเล่นวิดีโอ
        _controller.setLooping(true); // ตั้งค่าให้เล่นซ้ำอัตโนมัติเมื่อวิดีโอจบ
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
