import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:external_path/external_path.dart';
import 'dart:io';

class TabUSBScreen extends StatefulWidget {
  const TabUSBScreen({super.key});

  @override
  State<TabUSBScreen> createState() => _TabUSBScreenState();
}

class _TabUSBScreenState extends State<TabUSBScreen> {
  List<String> _storagePaths = [];
  String _selectedPath = '';
  String _imagePath = '';
  String _soundPath = '';
  String? _currentPath;

  final TextEditingController _selectedLogoPathController =
      TextEditingController();
  final TextEditingController _imagePathController = TextEditingController();
  final TextEditingController _soundPathController = TextEditingController();

  List<FileSystemEntity> _imageFiles = [];
  List<FileSystemEntity> _soundFiles = [];
  List<FileSystemEntity> _logoFiles = [];

  bool _isContentVisible = false; // Control visibility of content

  @override
  void initState() {
    super.initState();
    _listStoragePaths();
    _loadSettings();
  }

  Future<void> _listStoragePaths() async {
    final List<String> paths = [];
    final directory = await getApplicationDocumentsDirectory();
    paths.add(directory.path);

    try {
      final usbPaths = await ExternalPath.getExternalStorageDirectories();
      if (usbPaths.isNotEmpty) {
        paths.addAll(usbPaths);
      }
    } catch (e) {
      print("Error accessing USB storage: $e");
      if (!paths.contains(directory.path)) {
        paths.add(directory.path);
      }
    }

    setState(() {
      _storagePaths = paths;
    });
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('settingsBox');
    _selectedLogoPathController.text = box.get('logoPath', defaultValue: '');
    _imagePathController.text = box.get('imagePath', defaultValue: '');
    _soundPathController.text = box.get('soundPath', defaultValue: '');
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _imageFiles = [];
      _soundFiles = [];
      _logoFiles = [];
    });

    await _loadFilesForPath(_imagePathController.text, _imageFiles);
    await _loadFilesForPath(_soundPathController.text, _soundFiles);
    await _loadFilesForPath(_selectedLogoPathController.text, _logoFiles);
  }

  Future<void> _loadFilesForPath(
      String path, List<FileSystemEntity> fileList) async {
    if (path.isNotEmpty) {
      final directory = Directory(path);
      if (await directory.exists()) {
        final files = directory.listSync();
        setState(() {
          fileList.addAll(files);
        });
      }
    }
  }

  Future<void> _navigateToFolder(String path) async {
    final directory = Directory(path);
    if (await directory.exists()) {
      try {
        final subFolders = directory
            .listSync()
            .where((item) => item is Directory)
            .map((item) => item.path)
            .toList();

        if (subFolders.isNotEmpty) {
          setState(() {
            _currentPath = path;
            _storagePaths = subFolders;
          });
        } else {
          _showSnackbar('ไม่มีโฟลเดอร์ย่อยในไดเร็กทอรีนี้');
        }
      } catch (e) {
        _showSnackbar('Error accessing directory: $e');
      }
    } else {
      _showSnackbar('Directory does not exist.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showStoragePathsDialog(
      {String? path, TextEditingController? controller}) {
    if (path != null) {
      _currentPath = path;
    } else {
      _currentPath = null;
      _listStoragePaths();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a Folder'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _storagePaths.length,
              itemBuilder: (context, index) {
                final path = _storagePaths[index];
                final folderName = path.split('/').last;

                return ListTile(
                  title: Text(folderName),
                  subtitle: Text(path),
                  onTap: () {
                    _navigateToFolder(path);
                    Navigator.of(context).pop();
                    _showStoragePathsDialog(path: path, controller: controller);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_currentPath != null) {
                  setState(() {
                    if (controller == _imagePathController) {
                      _imagePath = _currentPath!;
                      _imagePathController.text = _imagePath;
                    } else if (controller == _soundPathController) {
                      _soundPath = _currentPath!;
                      _soundPathController.text = _soundPath;
                    } else {
                      _selectedPath = _currentPath!;
                      _selectedLogoPathController.text = _selectedPath;
                    }
                    _loadFiles();
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveSettings() async {
    final box = await Hive.openBox('settingsBox');
    await box.put('logoPath', _selectedLogoPathController.text);
    await box.put('imagePath', _imagePathController.text);
    await box.put('soundPath', _soundPathController.text);
    _showSnackbar('บันทึกการตั้งค่าเรียบร้อยแล้ว!');
  }

  void _checkPassword() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController passwordController =
            TextEditingController();

        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(hintText: 'Password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without action
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text == '0641318526') {
                  setState(() {
                    _isContentVisible =
                        true; // Show content if password is correct
                  });
                  Navigator.of(context).pop(); // Close dialog
                } else {
                  _showSnackbar('Incorrect password');
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        // Make the content scrollable
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (!_isContentVisible) // Show content only if visible
              IconButton(
                icon: Icon(Icons.lock), // Your icon here
                onPressed:
                    _checkPassword, // Show password dialog when icon is clicked
              ),
            const SizedBox(height: 20),
            if (_isContentVisible) // Show content only if visible
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText:
                          'Selected Logo Path (เลือกโฟลเดอร์เก้บรูปภาพโลโก้)',
                      hintText: 'Tap to select a folder',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _showStoragePathsDialog(
                        controller: _selectedLogoPathController),
                    controller: _selectedLogoPathController,
                  ),
                  const SizedBox(height: 10),
                  _buildFileList(_logoFiles),
                  const SizedBox(height: 20),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Image Path (เลือกโฟลเดอร์เก้บรูปภาพสไลด์)',
                      hintText: 'Tap to select an image',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _showStoragePathsDialog(
                        controller: _imagePathController),
                    controller: _imagePathController,
                  ),
                  const SizedBox(height: 10),
                  _buildFileList(_imageFiles),
                  const SizedBox(height: 20),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Sound Path  (เลือกโฟลเดอร์ที่เก็บเสียง)',
                      hintText: 'Tap to select a sound folder',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _showStoragePathsDialog(
                        controller: _soundPathController),
                    controller: _soundPathController,
                  ),
                  const SizedBox(height: 10),
                  _buildFileList(_soundFiles),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    child:
                        const Text('Save Settings (บันทึกการตั้งค่าหน้านี้)'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileList(List<FileSystemEntity> files) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: files.map((file) {
            final fileName = file.path.split('/').last;

            return Container(
              width: 100,
              child: Column(
                children: [
                  if (file is File && _isImageFile(file))
                    Image.file(
                      file,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  else if (file is File && _isSoundFile(file))
                    Icon(Icons.audiotrack, size: 80),
                  Text(fileName, textAlign: TextAlign.center),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  bool _isImageFile(File file) {
    return file.path.endsWith('.png') ||
        file.path.endsWith('.jpg') ||
        file.path.endsWith('.JPG') ||
        file.path.endsWith('.jpeg');
  }

  bool _isSoundFile(File file) {
    return file.path.endsWith('.mp3') ||
        file.path.endsWith('.mp4') ||
        file.path.endsWith('.wav');
  }
}
