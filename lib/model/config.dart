import 'package:flutter/widgets.dart' show BuildContext;

class Config {
  final String? azureTenantId;
  final String clientId;
  final String scope;
  final String responseType;
  final String redirectUri;
  final String? clientSecret;
  final String? resource;
  final String contentType;
  BuildContext? context;
  String? authorizationUrl;
  String? tokenUrl;
  final String nonce;
  final String tenant;
  final String policy;
  final String prompt;

  Config({
    this.azureTenantId,
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
