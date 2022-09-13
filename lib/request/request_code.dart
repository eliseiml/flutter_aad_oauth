part of '_request.dart';

class RequestCode extends IRequestCode {
  final StreamController<String?> _onCodeListener = StreamController();
  final Config _config;
  late AuthorizationRequest _authorizationRequest;

  Stream<String?>? _onCodeStream;

  RequestCode(Config config) : _config = config {
    _authorizationRequest = AuthorizationRequest(config);
  }

  @override
  Future<String?> requestCode() async {
    String? code;
    final String urlParams = constructUrlParams(_authorizationRequest.parameters);
    if (_config.context != null) {
      String initialURL =
          ('${_authorizationRequest.url}?$urlParams').replaceAll(' ', '%20');

      await _mobileAuth(initialURL);
    } else {
      throw Exception('Context is null. Please call setContext(context).');
    }

    code = await _onCode.first;
    return code;
  }

  _mobileAuth(String initialURL) async {
    var webView = WebView(
      initialUrl: initialURL,
      javascriptMode: JavascriptMode.unrestricted,
      onPageFinished: (url) => _getUrlData(url),
      navigationDelegate: (request) {
        if (request.url.startsWith(_config.redirectUri)) {
          if (Platform.isIOS) {
            _getUrlData(request.url);
          }
          return NavigationDecision.prevent;
        } else {
          return NavigationDecision.navigate;
        }
      },
    );

    await Navigator.of(_config.context!).push(
        MaterialPageRoute(builder: (context) => SafeArea(child: webView)));
  }

  _getUrlData(String _url) {
    var url = _url.replaceFirst('#', '?');
    Uri uri = Uri.parse(url);

    if (uri.queryParameters['error'] != null) {
      Navigator.of(_config.context!).pop();
      _onCodeListener
          .addError(Exception('Access denied or authentication canceled.'));
    }

    var token = uri.queryParameters['code'];
    if (token != null) {
      _onCodeListener.add(token);
      Navigator.of(_config.context!).pop();
    }
  }

  @override
  Future<void> clearCookies() async {
    await CookieManager().clearCookies();
  }

  Stream<String?> get _onCode =>
      _onCodeStream ??= _onCodeListener.stream.asBroadcastStream();

  @override
  void setContext(BuildContext context) {
    _config.context = context;
  }
}
