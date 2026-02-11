import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:login_statistics/helpers/base_view/base_view.dart';
import 'package:login_statistics/models/response_data.dart';
import 'package:login_statistics/widgets/buttons/primary_button.dart';
import 'package:permission_handler/permission_handler.dart';
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
  Timer? apiTimer;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isAndroid) {
      Permission.manageExternalStorage.request();
    }
    // TODO: implement initState
    super.initState();
  }

  void _sendRequest(bool initial) async {
    String curlCommand = '';

    /// Regex to find and replace the pageSize and pageToken parameters
    final pageSizeRegex = RegExp(r'pageSize=\d+');
    final pageTokenRegex = RegExp(r'pageToken=[^&]*');

    /// New values to replace
    const int newPageSize = 25;

    if (initial) {
      data = [];
      nextPageToken = '';
      originalCurl = _controller.text;
      indexDay = 0;
      daysToExtract = 0;
      print('curl: $originalCurl');
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

    /// Extract cookie if present
    RegExp cookieRegex = RegExp(r"-b '([^']+)'");
    final cookieMatch = cookieRegex.firstMatch(curlCommand);
    if (cookieMatch != null) {
      headers['Cookie'] = cookieMatch.group(1)!;
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
      print('headers: $headers');

      /// Update the curlCommand with the new startTime and endTime
      final response = await http
          .get(
            updatedUri,
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));
      print('response: $response');
      print('response: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('response.body: ${response.body}');
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
            done(true);
          } else {
            _sendRequest(false);
          }
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        done(false);
      }
    } catch (e) {
      print('Error: $e');
      done(false);
    }
  }

  void done(bool success) async {
    if (success) {
      print('///////////////////////////DONE///////////////////////////');
    } else {
      print('Failed Done');
      print('Last Next Page Token: $nextPageToken');
      print(
          'Last Start Time: ${dateRanges[indexDay]['startTime']!.toIso8601String()}');
      print(
          'Last End Time: ${dateRanges[indexDay]['endTime']!.toIso8601String()}');

      ///remove failed
      _removeLastDayData();
    }
    hideLoadingDialog();

    ///do the xlsx creation
    generateExcel();
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

    /// Get the path to the Downloads directory
    Directory? downloadsDirectory = Directory('/storage/emulated/0/Download');

    String outputPath = '${downloadsDirectory.path}/output_file.xlsx';

    /// Save the Excel file
    var fileBytes = excel.save();

    File(outputPath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    print('Excel file created at $outputPath');
    hideLoadingDialog();
  }

  void _removeLastDayData() {
    if (indexDay <= 0 || indexDay > dateRanges.length) return;

    /// The failed day is the current indexDay
    final failedDateKey =
        DateFormat('MM/dd').format(dateRanges[indexDay]['endTime']!);

    print('Removing incomplete data for: $failedDateKey');

    data.removeWhere((element) => element.keys.first == failedDateKey);
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
        ],
      );
}
