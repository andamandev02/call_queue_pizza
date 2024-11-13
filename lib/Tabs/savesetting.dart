// void _generateList1() async {
//   String inputText = textController.text;

//   // Regular expression to match the text format like "เชิญหมายเลข 0-999 ค่ะ"
//   RegExp regExp = RegExp(r"(.*?)(\d+)-(\d+)(.*)");
//   Match? match = regExp.firstMatch(inputText);

//   if (match != null) {
//     String baseText = match.group(1)!.trim(); // "เชิญหมายเลข"
//     int start = int.parse(match.group(2)!); // 0
//     int end = int.parse(match.group(3)!); // 999
//     String endText = match.group(4)!.trim(); // "ค่ะ"

//     // Generate the list based on the range
//     List<String> tempList = List.generate(
//       end - start + 1,
//       (index) => "$baseText ${start + index} $endText",
//     );

//     for (String item in tempList) {
//       await _saveSettings(item); // Use await to wait for each request
//     }

//     setState(() {
//       generatedList = tempList;
//     });
//   } else {
//     setState(() {
//       generatedList = [inputText];
//     });
//   }
// }
