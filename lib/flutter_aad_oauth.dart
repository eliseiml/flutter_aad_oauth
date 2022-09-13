library flutter_aad_oauth;

import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

import 'helper/_helper.dart';
import 'model/_model.dart';
import 'request/_request.dart';

export 'model/_model.dart' show Config;

class FlutterAadOauth {
  static late Config _config;
  AuthStorage? _authStorage;
  Token? _token;
  late IRequestCode _requestCode;
  late RequestToken _requestToken;
  final _logger = FlutterAadLogger();
  Function(String)? loginCallback;

  FlutterAadOauth(
    config, {
    this.loginCallback,
  }) {
    FlutterAadOauth._config = config;
    _authStorage = _authStorage ?? AuthStorage();
    _requestCode = kIsWeb ? RequestCodeWeb(_config) : RequestCode(_config);
    _requestToken = RequestToken(_config);
  }

  Future<void> initialize() async {
    if (!kIsWeb) return;
    try {
      final initialLink = await getInitialLink();
      _logger.log('INITIAL LINK: $initialLink');

      if (initialLink == null || initialLink.isEmpty) return;
      final uri = Uri.parse(initialLink.replaceAll('#', '?'));
      final code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        _logger.log('Code: $code');
        await _performFullAuthFlow(authCode: code);
      }
    } on Exception catch (e) {
      _logger.log('Init error: $e');
    }
  }

  void setContext(BuildContext context) {
    _config.context = context;
    _requestToken.setContext(context);
    _requestCode.setContext(context);
  }

  Future<void> login() async {
    await _removeOldTokenOnFirstLogin();
    if (!Token.tokenIsValid(_token)) await _performAuthorization();
  }

  Future<String?> getAccessToken() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token?.accessToken;
  }

  Future<String?> getIdToken() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token?.idToken;
  }

  Future<String?> getRefreshToken() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token?.refreshToken;
  }

  Future<String?> getTokenType() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token?.tokenType;
  }

  Future<DateTime?> getIssueTimeStamp() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token?.issueTimeStamp;
  }

  Future<DateTime?> getExpireTimeStamp() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token?.expireTimeStamp;
  }

  Future<int?> getExpiresIn() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token?.expiresIn;
  }

  Future<bool> tokenIsValid({refreshIfNot = true}) async {
    _token ??= await _authStorage?.loadTokenFromCache();
    if (Token.tokenIsValid(_token)) return true;
    if (refreshIfNot) {
      await _performRefreshAuthFlow();
      return Token.tokenIsValid(_token);
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    await _authStorage?.clear();
    await _requestCode.clearCookies();
    _token = null;
    FlutterAadOauth(_config);
  }

  Future<void> _performAuthorization() async {
    // load token from cache
    _token = await _authStorage?.loadTokenFromCache();
    //still have refresh token / try to get new access token with refresh token
    if (_token?.refreshToken != null) {
      await _performRefreshAuthFlow();
    } else {
      try {
        await _performFullAuthFlow();
      } catch (e) {
        rethrow;
      }
    }

    //save token to cache
    await _authStorage!.saveTokenToCache(_token);
  }

  Future<void> _performFullAuthFlow({String? authCode}) async {
    var code = authCode;
    try {
      code ??= await _requestCode.requestCode();
      _token = await _requestToken.requestToken(code);
      if (_token != null && _token!.accessToken != null) {
        loginCallback!(_token!.accessToken!);
      }
      _logger.log('Token: $_token');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _performRefreshAuthFlow() async {
    if (_token?.refreshToken != null) {
      try {
        _token = await _requestToken.requestRefreshToken(_token!.refreshToken);
      } catch (e) {
        //do nothing (because later we try to do a full oauth code flow request)
      }
    } else {
      await _performFullAuthFlow();
    }
  }

  Future<void> _removeOldTokenOnFirstLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    const _keyFreshInstall = 'freshInstall';
    if (!prefs.containsKey(_keyFreshInstall)) {
      await logout();
      await prefs.setBool(_keyFreshInstall, false);
    }
  }
}
