// ignore_for_file: prefer_initializing_formals
part of '_model.dart';

class AuthorizationRequest {
  String? url;
  String? redirectUrl;
  late Map<String, String> parameters;
  Map<String, String>? headers;
  bool? fullScreen;
  bool? clearCookies;

  AuthorizationRequest(Config config,
      {bool fullScreen = true, bool clearCookies = false}) {
    url = config.authorizationUrl;
    redirectUrl = config.redirectUri;
    parameters = {
      'p': config.policy,
      'client_id': config.clientId,
      'response_type': config.responseType,
      'redirect_uri': config.redirectUri,
      'scope': config.scope,
      'prompt': config.prompt,
      'code_challenge': config.codeChallenge,
      'code_challenge_method': config.codeChallengeMethod
    };

    if (kIsWeb) {
      parameters.addAll({'nonce': config.nonce});
    }
    this.fullScreen = fullScreen;
    this.clearCookies = clearCookies;
  }
}
