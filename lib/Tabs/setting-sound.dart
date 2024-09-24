import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class TabSoundScreen extends StatefulWidget {
  const TabSoundScreen({super.key});

  @override
  _TabSoundScreenState createState() => _TabSoundScreenState();
}

class _TabSoundScreenState extends State<TabSoundScreen> {
  // Controllers for text input fields
  final TextEditingController textController = TextEditingController();
  final TextEditingController speakerController = TextEditingController();
  final TextEditingController volumeController = TextEditingController();
  final TextEditingController speedController = TextEditingController();
  final TextEditingController typeMediaController = TextEditingController();
  final TextEditingController saveFileController = TextEditingController();
  final TextEditingController languageController = TextEditingController();

  Future<void> _saveSettings() async {
    String apiUrl = 'https://api-voice.botnoi.ai/openapi/v1/generate_audio';
    String token = 'SWNMcmZwMXhic1phYzdGV2RVZ0IydmRxT1dDMzU2MTg5NA==';

    var body = jsonEncode({
      'text': textController.text,
      'speaker': speakerController.text,
      'volume': double.tryParse(volumeController.text) ?? 1.0,
      'speed': double.tryParse(speedController.text) ?? 1.0,
      'type_media': typeMediaController.text,
      'save_file': saveFileController.text.toLowerCase() == 'true',
      'language': languageController.text
    });

    // Make the POST request
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Botnoi-Token': token,
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      String audioUrl = responseData['audio_url'];
      print('Audio URL: $audioUrl');

      if (await canLaunch(audioUrl)) {
        await launch(audioUrl);
      } else {
        print('Could not launch $audioUrl');
      }
    } else {
      print('Error: ${response.statusCode}, Response: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: textController,
                    decoration: InputDecoration(labelText: 'Text'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: speakerController,
                    decoration: InputDecoration(labelText: 'Speaker'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Second row: Volume, Speed, and Type Media
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: volumeController,
                    decoration: InputDecoration(labelText: 'Volume'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: speedController,
                    decoration: InputDecoration(labelText: 'Speed'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: typeMediaController,
                    decoration: InputDecoration(labelText: 'Type Media'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Third row: Save File and Language
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: saveFileController,
                    decoration:
                        InputDecoration(labelText: 'Save File (true/false)'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: languageController,
                    decoration: InputDecoration(labelText: 'Language'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Save button
            Center(
              child: ElevatedButton(
                onPressed: _saveSettings,
                // onPressed: () {},
                child: const Text('บันทึกการตั้งค่า'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
