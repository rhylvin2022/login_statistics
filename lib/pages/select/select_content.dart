import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:login_statistics/helpers/base_view/base_view.dart';
import 'package:login_statistics/models/response_data.dart';
import 'package:login_statistics/widgets/buttons/primary_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class SelectContent extends BaseView {
  const SelectContent({Key? key}) : super(key: key);

  @override
  _SelectContentState createState() => _SelectContentState();
}

class _SelectContentState extends BaseViewState {
  final TextEditingController _controller = TextEditingController();
  String originalCurl = "";
  String nextPageToken = "";
  String searchTerm = "";
  String originalStartTime = "";
  String originalEndTime = "";
  int daysToExtract = 0;
  int indexDay = 0;
  late List<Map<String, String>> data;
  List<Map<String, DateTime>> dateRanges = [];
  String selectableText = "";

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isAndroid) {
      // await MediaStore.ensureInitialized();

      saveFileToDownloads();
    }
    // TODO: implement initState
    super.initState();
  }

  Future<void> saveFileToDownloads() async {
    var status = await Permission.storage.status;
    var statusCamera = await Permission.camera.status;
    print('status: $status');
    print('statusCamera: $statusCamera');
    // Permission.storage.request();
    Permission.storage.request();
    print('requesting');

    // openAppSettings();
    // if (!status.isGranted) {
    //   print('requesting');
    //
    //   /// Request permission
    //   var result = await Permission.storage.request();
    //   if (result.isGranted) {
    //     print("Storage permission granted");
    //   } else {
    //     print("Storage permission denied");
    //   }
    // } else {
    //   print("Storage permission already granted");
    // }
  }

  Future<Directory?> getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  void _sendRequest(bool initial) async {
    String curlCommand = '';

    /// Regex to find and replace the pageSize and pageToken parameters
    final pageSizeRegex = RegExp(r'pageSize=\d+');
    final pageTokenRegex = RegExp(r'pageToken=[^&]*');

    /// New values to replace
    const int newPageSize = 999;

    if (initial) {
      data = [];
      nextPageToken = '';
      originalCurl = _controller.text;
      indexDay = 0;
      daysToExtract = 0;
    }
    curlCommand = originalCurl;

    /// Update pageSize
    if (pageSizeRegex.hasMatch(curlCommand)) {
      curlCommand =
          curlCommand.replaceFirst(pageSizeRegex, 'pageSize=$newPageSize');
    } else {
      curlCommand += '&pageSize=$newPageSize';
    }

    /// Update pageToken
    if (pageTokenRegex.hasMatch(curlCommand) && nextPageToken != '') {
      curlCommand =
          curlCommand.replaceFirst(pageTokenRegex, 'pageToken=$nextPageToken');
    } else {
      curlCommand += '&pageToken=$nextPageToken';
    }

    originalCurl = curlCommand;
    print('curl: $originalCurl');

    /// Parse the cURL command to extract URL and headers
    Map<String, String> headers = {};
    String url = '';

    /// Find the URL
    RegExp urlRegex = RegExp(r"curl '(https?://[^\s']+)'");
    final urlMatch = urlRegex.firstMatch(curlCommand);
    if (urlMatch != null) {
      url = urlMatch.group(1)!;
    }

    /// Find the headers
    RegExp headerRegex = RegExp(r"-H '(.+?): (.+?)'");
    final headerMatches = headerRegex.allMatches(curlCommand);
    for (var match in headerMatches) {
      headers[match.group(1)!] = match.group(2)!;
    }

    if (initial) {
      /// Extract the query parameters
      Map<String, String> queryParams =
          Map<String, String>.from(Uri.parse(url).queryParameters);
      searchTerm = queryParams['searchTerm'] ?? '';
      originalStartTime = queryParams['startTime'] ?? '';
      originalEndTime = queryParams['endTime'] ?? '';
      print('Original startTime: $originalStartTime');
      print('Original endTime: $originalEndTime');

      DateTime startOriginalDateTime = DateTime.parse(originalStartTime);
      DateTime endOriginalDateTime = DateTime.parse(originalEndTime);
      print('startDateTime: $startOriginalDateTime');
      print('endDateTime: $endOriginalDateTime');

      Duration duration = endOriginalDateTime.difference(startOriginalDateTime);
      print('duration: $duration');

      double totalDays = duration.inHours / 24;
      int roundedDays = totalDays.round();
      print('roundedDays: $roundedDays');
      daysToExtract = roundedDays;

      dateRanges.clear();
      for (int i = 0; i < daysToExtract; i++) {
        DateTime startDate = startOriginalDateTime.add(Duration(days: i));
        DateTime endDate = startDate.add(const Duration(days: 1));

        dateRanges.add({
          'startTime': startDate,
          'endTime': endDate,
        });
      }

      int i = 0;
      dateRanges.forEach((element) {
        print('$i $element');
        i++;
      });

      headers.forEach((key, value) {
        print('$key = $value');
      });
    }

    ///do API call with updated date range.
    ///
    try {
      Uri uri = Uri.parse(url);
      Map<String, String> queryParams = uri.queryParameters;
      Uri updatedUri = uri.replace(
        queryParameters: {
          ...queryParams,
          'startTime': dateRanges[indexDay]['startTime']!.toIso8601String(),
          'endTime': dateRanges[indexDay]['endTime']!.toIso8601String(),
          'pageSize': newPageSize.toString(),
          'pageToken': nextPageToken,
        },
      );
      print('updatedUri: $updatedUri');

      /// Update the curlCommand with the new startTime and endTime
      final response = await http.get(updatedUri, headers: headers);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);
        ResponseData responseData = ResponseData.fromJson(jsonMap);

        responseData.traces!.forEach((element) {
          String userID = (element.traceId!.replaceAll(searchTerm, ''));
          String loginDate =
              DateFormat('MM/dd').format(dateRanges[indexDay]['endTime']!);
          data.add({loginDate: userID});
        });
        print('nextPageToken: ${responseData.nextPageToken}');
        if (responseData.nextPageToken != null) {
          nextPageToken = responseData.nextPageToken!;
          _sendRequest(false);
        } else {
          nextPageToken = '';
          indexDay++;
          print('indexDay: $indexDay');
          if (indexDay == daysToExtract) {
            print('///////////////////////////DONE///////////////////////////');

            hideLoadingDialog();

            ///done

            ///do the xlsx creation
            generateExcel();

            ///do copy text
            generateSelectableText();
          } else {
            _sendRequest(false);
          }
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        print('Error: $e');
      });
    }
  }

  Future<void> generateExcel() async {
    /// Create a new Excel document
    var excel = Excel.createExcel();

    /// Select the default sheet
    Sheet sheetObject = excel['Sheet1'];

    print('data count: ${data.length}');

    /// Loop through the data asynchronously
    await Future.forEach(data, (element) async {
      /// Convert the date and value to proper types
      var dateCell = CellIndex.indexByString("A${sheetObject.maxRows + 1}");
      var valueCell = CellIndex.indexByString("B${sheetObject.maxRows + 1}");
      sheetObject.cell(dateCell).value = TextCellValue(element.keys.first);
      sheetObject.cell(valueCell).value = TextCellValue(element.values.first);

      print('${element.keys} : ${element.values}');
      await Future.delayed(const Duration(milliseconds: 1));
    });

    if (await Permission.storage.request().isGranted) {
      print('hello world');

      /// Get the path to the Downloads directory
      Directory? downloadsDirectory = Directory('/storage/emulated/0/Download');

      String outputPath = '${downloadsDirectory.path}/output_file.xlsx';

      /// Save the Excel file
      var fileBytes = excel.save();

      ///Delete file if existing
      // File file = File(outputPath);
      //
      // if (file.existsSync()) {
      //   file.deleteSync();
      // }

      File(outputPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);

      /// Write the file to the local system, creating or replacing if necessary
      // file.writeAsBytesSync(fileBytes!, flush: true);

      print('Excel file created at $outputPath');
      hideLoadingDialog();
    }
  }

  Future<void> generateSelectableText() async {
    /// Create a formatted string from the data
    setState(() {
      selectableText =
          // data
          // .map((entry) => '${entry.keys.first}: ${entry.values.first}')
          // .join('\n');
          data
              .map((entry) => '${entry.keys.first}\t${entry.values.first}')
              .join('\n');
    });

    // Copy formatted data to clipboard
    Clipboard.setData(ClipboardData(text: selectableText));

    // Show toast message
    Fluttertoast.showToast(
      msg: "Text copied to clipboard successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget rootWidget(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter your curl',
              hintText: 'Paste your curl here',
            ),
            controller: _controller,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          PrimaryButton(
            buttonText: 'Extract',
            onPressed: () {
              Permission.storage.request();
              showLoadingDialog();
              _sendRequest(true);
              FocusScope.of(context).unfocus();
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          // selectableText != ""
          //     ? SingleChildScrollView(
          //         child: SelectableText(
          //           selectableText,
          //           style: const TextStyle(fontSize: 18),
          //         ),
          //       )
          //     : Container(),
        ],
      );
}
