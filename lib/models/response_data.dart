import 'package:login_statistics/models/traces.dart';

class ResponseData {
  List<Traces>? traces;

  String? nextPageToken;

  String? totalSize;

  ResponseData();

  @override
  String toString() {
    return 'ResetPasswordResponse[traces=$traces, nextPageToken=$nextPageToken, totalSize=$totalSize]';
  }

  ResponseData.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    traces = Traces.listFromJson(json['traces']);
    nextPageToken = json['nextPageToken'];
    totalSize = json['totalSize'];
  }

  Map<String, dynamic> toJson() {
    return {
      'traces': traces,
      'nextPageToken': nextPageToken,
      'totalSize': totalSize,
    };
  }

  static List<ResponseData> listFromJson(List<dynamic>? json) {
    return json == null
        ? <ResponseData>[]
        : json.map((value) => ResponseData.fromJson(value)).toList();
  }

  static Map<String, ResponseData> mapFromJson(
      Map<String, Map<String, dynamic>> json) {
    var map = <String, ResponseData>{};
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) =>
          map[key] = ResponseData.fromJson(value));
    }
    return map;
  }
}
