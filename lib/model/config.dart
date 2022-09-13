part of '_model.dart';

class Config {
  final String clientId;
  final String scope;
  final String responseType;
  final String redirectUri;
  final String? clientSecret;
  final String? resource;
  final String contentType;
  final String nonce;
  final String tenant;
  final String policy;
  final String prompt;
  BuildContext? context;
  String? authorizationUrl;
  String? tokenUrl;

  /*
  * codeVerifier is randomly created string (should be longer than 32 symbols);
  * codeChallenge is SHA256 checksum taken from codeVerifier;
  * These parameters are used for requests security. They should be created here,
  * on the client's side.
  *
  * In this case they are hardcoded as we don't need this option
  */
  String get codeChallenge => '_r67lcj4MoDNBAkhxS7ke_YKhKCBAiM0SgzNCagbCxo';
  String get codeVerifier => '1qaz2wsx3edc4rfv5tgb6yhn1234567890qwertyuiop';
  String get codeChallengeMethod => 'S256';

  Config({
    required this.tenant,
    required this.clientId,
    required this.scope,
    required this.redirectUri,
    required this.responseType,
    required this.policy,
    required this.prompt,
    this.clientSecret,
    this.resource,
    this.contentType = 'application/x-www-form-urlencoded',
    this.context,
    this.nonce = 'nonce_value',
  }) {
    authorizationUrl =
        'https://$tenant.b2clogin.com/$tenant.onmicrosoft.com/$policy/oauth2/v2.0/authorize';
    tokenUrl =
        'https://$tenant.b2clogin.com/$tenant.onmicrosoft.com/$policy/oauth2/v2.0/token';
  }
}
