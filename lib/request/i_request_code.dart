part of '_request.dart';

abstract class IRequestCode {
  Future<String?> requestCode();
  Future<void> clearCookies();
  void setContext(BuildContext context);

  String constructUrlParams(Map<String, String> params) {
    final queryParams = <String>[];
    params
        .forEach((String key, String value) => queryParams.add('$key=$value'));
    return queryParams.join('&');
  }
}