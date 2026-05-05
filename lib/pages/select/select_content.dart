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

  static const int _maxRetries = 3;
  int _retryCount = 0;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isAndroid) {
      Permission.manageExternalStorage.request();
    }
    super.initState();
  }

  void _sendRequest(bool initial) async {
    String curlCommand = '';

    final pageSizeRegex = RegExp(r'pageSize=\d+');
    final pageTokenRegex = RegExp(r'pageToken=[^&]*');
    const int newPageSize = 25;

    if (initial) {
      data = [];
      nextPageToken = '';
      originalCurl = _controller.text;
      indexDay = 0;
      daysToExtract = 0;
      _retryCount = 0;
      print('curl: $originalCurl');
    }
    curlCommand = originalCurl;

    if (pageSizeRegex.hasMatch(curlCommand)) {
      curlCommand =
          curlCommand.replaceFirst(pageSizeRegex, 'pageSize=$newPageSize');
    } else {
      curlCommand += '&pageSize=$newPageSize';
    }

    if (pageTokenRegex.hasMatch(curlCommand) && nextPageToken != '') {
      curlCommand =
          curlCommand.replaceFirst(pageTokenRegex, 'pageToken=$nextPageToken');
    } else {
      curlCommand += '&pageToken=$nextPageToken';
    }

    Map<String, String> headers = {};
    String url = '';

    RegExp urlRegex = RegExp(r"curl '(https?://[^\s']+)'");
    final urlMatch = urlRegex.firstMatch(curlCommand);
    if (urlMatch != null) {
      url = urlMatch.group(1)!;
    }

    RegExp headerRegex = RegExp(r"-H '(.+?): (.+?)'");
    final headerMatches = headerRegex.allMatches(curlCommand);
    for (var match in headerMatches) {
      headers[match.group(1)!] = match.group(2)!;
    }

    RegExp cookieRegex = RegExp(r"-b '([^']+)'");
    final cookieMatch = cookieRegex.firstMatch(curlCommand);
    if (cookieMatch != null) {
      headers['Cookie'] = cookieMatch.group(1)!;
    }

    if (initial) {
      Map<String, String> queryParams =
          Map<String, String>.from(Uri.parse(url).queryParameters);
      searchTerm = queryParams['searchTerm'] ?? '';
      originalStartTime = queryParams['startTime'] ?? '';
      originalEndTime = queryParams['endTime'] ?? '';

      DateTime startOriginalDateTime = DateTime.parse(originalStartTime);
      DateTime endOriginalDateTime = DateTime.parse(originalEndTime);

      Duration duration = endOriginalDateTime.difference(startOriginalDateTime);
      double totalDays = duration.inHours / 24;
      int roundedDays = totalDays.round();
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
    }

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

      final response = await http
          .get(updatedUri, headers: headers)
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        _retryCount = 0;
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
        if (_retryCount < _maxRetries) {
          _retryCount++;
          print('Retrying... attempt $_retryCount of $_maxRetries');
          await Future.delayed(const Duration(seconds: 3));
          _sendRequest(false);
        } else {
          print('Max retries reached after non-200 response. Giving up.');
          _retryCount = 0;
          done(false);
        }
        // ─────────────────────────────────────────────────────────
      }
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      if (_retryCount < _maxRetries) {
        _retryCount++;
        print('Retrying after timeout... attempt $_retryCount of $_maxRetries');
        await Future.delayed(const Duration(seconds: 5));
        _sendRequest(false);
      } else {
        print('Max retries reached after timeout. Giving up.');
        _retryCount = 0;
        done(false);
      }
    } catch (e) {
      print('Error: $e');
      if (_retryCount < _maxRetries) {
        _retryCount++;
        print('Retrying after error... attempt $_retryCount of $_maxRetries');
        await Future.delayed(const Duration(seconds: 3));
        _sendRequest(false);
      } else {
        print('Max retries reached after error. Giving up.');
        _retryCount = 0;
        done(false);
      }
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
      _removeLastDayData();
    }
    generateExcel();
  }

  Future<void> generateExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    print('data count: ${data.length}');

    await Future.forEach(data, (element) async {
      var dateCell = CellIndex.indexByString("A${sheetObject.maxRows + 1}");
      var valueCell = CellIndex.indexByString("B${sheetObject.maxRows + 1}");
      sheetObject.cell(dateCell).value = TextCellValue(element.keys.first);
      sheetObject.cell(valueCell).value = TextCellValue(element.values.first);
      await Future.delayed(const Duration(milliseconds: 1));
    });

    Directory? downloadsDirectory = Directory('/storage/emulated/0/Download');
    String outputPath = '${downloadsDirectory.path}/output_file.xlsx';
    var fileBytes = excel.save();

    File(outputPath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    print('Excel file created at $outputPath');
    hideLoadingDialog();
  }

  void _removeLastDayData() {
    if (indexDay <= 0 || indexDay > dateRanges.length) return;
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
