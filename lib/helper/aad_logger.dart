part of '_helper.dart';

class FlutterAadLogger {
  void log(String message) {
    debugPrint('## Azure B2C ##: $message');
  }
}