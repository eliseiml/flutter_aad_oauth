part of '_request.dart';

class RequestCodeWeb extends IRequestCode {
  final Config _config;
  late AuthorizationRequest _authorizationRequest;

  RequestCodeWeb(Config config) : _config = config {
    _authorizationRequest = AuthorizationRequest(config);
  }

  @override
  Future<String?> requestCode() async {
    final String urlParams = constructUrlParams(_authorizationRequest.parameters);
    if (_config.context != null) {
      String initialURL =
          ('${_authorizationRequest.url}?$urlParams').replaceAll(' ', '%20');

      await _webAuth(initialURL);
    } else {
      throw Exception('Context is null. Please call setContext(context).');
    }

    return null;
  }

  _webAuth(String initialURL) async {
    html.window.location.replace(initialURL);
  }

  @override
  Future<void> clearCookies() async {
    return;
  }

  @override
  void setContext(BuildContext context) {
    _config.context = context;
  }
}
