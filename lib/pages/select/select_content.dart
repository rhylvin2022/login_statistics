import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveFileToDownloads();
  }

  Future<void> saveFileToDownloads() async {
    // Request storage permission
    if (await _requestPermission(Permission.storage)) {
      // Directory? downloadsDirectory = await getDownloadsDirectory();
      //
      // if (downloadsDirectory != null) {
      //   String filePath = "${downloadsDirectory.path}/my_file.txt";
      //
      //   // Create a text file
      //   File file = File(filePath);
      //
      //   // Write some text to the file
      //   await file.writeAsString('This is a sample text written to the file.');
      //
      //   print("File saved at: $filePath");
      // } else {
      //   print("Could not access Downloads directory.");
      // }
    } else {
      print("Permission denied.");
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
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
      nextPageToken = '';
      originalCurl = _controller.text;
      curlCommand = originalCurl;
    } else {
      curlCommand = originalCurl;
    }

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

    // Extract the query parameters
    Map<String, String> queryParams =
        Map<String, String>.from(Uri.parse(url).queryParameters);
    // print('queryParams[searchTerm]: ${queryParams['searchTerm']}');
    searchTerm = queryParams['searchTerm'] ?? '';

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);
        ResponseData data = ResponseData.fromJson(jsonMap);

        data.traces!.forEach((element) {
          print((element.traceId!.replaceAll(searchTerm, '')));
        });
        print('nextPageToken: ${data.nextPageToken}');
        if (data.nextPageToken != null) {
          nextPageToken = data.nextPageToken!;
          _updateRequest();
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

  void _updateRequest() {
    _sendRequest(false);
  }

  @override
  Widget rootWidget(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // PrimaryButton(
          //   buttonText: 'Texas Holdem',
          //   onPressed: () {
          //     context.beamToNamed(NavigationRoutes.texasHoldem);
          //   },
          // ),
          // SizedBox(
          //   height: MediaQuery.of(context).size.height * 0.03,
          // ),
          // SecondaryButton(
          //   buttonText: 'Texas Holdem Generator',
          //   onPressed: () {
          //     context.beamToNamed(NavigationRoutes.texasHoldemGenerator);
          //   },
          // ),
          // SizedBox(
          //   height: MediaQuery.of(context).size.height * 0.06,
          // ),
          // PrimaryButton(
          //   buttonText: 'PLO',
          //   onPressed: () {
          //     context.beamToNamed(NavigationRoutes.plo);
          //   },
          // ),
          // SizedBox(
          //   height: MediaQuery.of(context).size.height * 0.03,
          // ),
          // SecondaryButton(
          //   buttonText: 'PLO Generator',
          //   onPressed: () {
          //     context.beamToNamed(NavigationRoutes.ploGenerator);
          //   },
          // ),
          TextField(
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter your curl',
              hintText: 'Paste your curl here',
            ),
            controller: _controller,
          ),
          PrimaryButton(
            buttonText: 'Extract',
            onPressed: () {
              _sendRequest(true);
            },
          ),
        ],
      );
}
