class Traces {
  String? appId;

  String? traceId;

  String? traceType;

  Traces();

  @override
  String toString() {
    return 'Traces[appId=$appId, traceId=$traceId, traceType=$traceType]';
  }

  Traces.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    appId = json['appId'];
    traceId = json['traceId'];
    traceType = json['traceType'];
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'traceId': traceId,
      'traceType': traceType,
    };
  }

  static List<Traces> listFromJson(List<dynamic> json) {
    return json == null
        ? <Traces>[]
        : json.map((value) => Traces.fromJson(value)).toList();
  }

  static Map<String, Traces> mapFromJson(
      Map<String, Map<String, dynamic>> json) {
    var map = new Map<String, Traces>();
    if (json != null && json.length > 0) {
      json.forEach((String key, Map<String, dynamic> value) =>
          map[key] = Traces.fromJson(value));
    }
    return map;
  }
}
