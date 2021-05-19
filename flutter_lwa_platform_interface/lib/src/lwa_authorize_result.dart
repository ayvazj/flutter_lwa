part of '../flutter_lwa_platform_interface.dart';

T? cast<T>(x) => x is T ? x : null;

/// The response from LWA APIs.
class LwaAuthorizeResult {
  /// The access token returned by the LWA login, which can be used to
  /// access Amazon APIs.
  final String? accessToken;

  /// The access token returned by the LWA login, which can be used to
  /// access Amazon APIs.
  final String? authorizationCode;

  final String? clientId;

  final String? redirectURI;

  LwaAuthorizeResult.empty()
      : accessToken = null,
        authorizationCode = null,
        clientId = null,
        redirectURI = null;

  bool get isLoggedIn {
    return accessToken != null && accessToken!.isNotEmpty;
  }

  /// Constructs instance from a [Map].
  LwaAuthorizeResult.fromMap(Map<String, dynamic> map)
      : accessToken = cast<String>(map['accessToken']),
        authorizationCode = cast<String>(map['authorizationCode']),
        clientId = cast<String>(map['clientId']),
        redirectURI = cast<String>(map['redirectURI']);

  /// Transforms instance to a [Map].
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accessToken': accessToken,
      'authorizationCode': authorizationCode,
      'clientId': clientId,
      'redirectURI': redirectURI,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LwaAuthorizeResult &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          authorizationCode == other.authorizationCode &&
          clientId == other.clientId &&
          redirectURI == other.redirectURI;

  @override
  int get hashCode =>
      accessToken.hashCode ^
      authorizationCode.hashCode ^
      clientId.hashCode ^
      redirectURI.hashCode;
}
