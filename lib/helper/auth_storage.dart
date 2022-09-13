part of '_helper.dart';

class AuthStorage {
  static AuthStorage shared = AuthStorage();
  late IStorage _storage;
  late String _identifier = 'Token';
  AuthStorage({String tokenIdentifier = ''}) {
    _identifier += tokenIdentifier;
    if (kIsWeb) {
      _storage = WebStorage();
    } else {
      _storage = MobileStorage();
    }
  }
  Future<void> saveTokenToCache(Token? token) async {
    var data = Token.toJsonMap(token);
    var json = convert.jsonEncode(data);
    await _storage.write(key: _identifier, value: json);
  }

  Future<T?> loadTokenFromCache<T extends Token>() async {
    var json = await _storage.read(key: _identifier);
    if (json == null) return null;
    try {
      var data = convert.jsonDecode(json);
      return _getTokenFromMap<T>(data) as FutureOr<T?>;
    } catch (exception) {
      return null;
    }
  }

  Token _getTokenFromMap<T extends Token>(Map<String, dynamic>? data) => Token.fromJson(data);

  Future clear() async {
    await _storage.delete(key: _identifier);
  }
}
