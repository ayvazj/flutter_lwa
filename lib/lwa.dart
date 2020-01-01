import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'scope.dart';

part 'widgets.dart';

const package_name = 'flutter_lwa';

const MethodChannel _channel =
    const MethodChannel('com.github.ayvazj/$package_name');

/// The response from LWA APIs.
class LwaAuthorizeResult {
  /// The access token returned by the LWA login, which can be used to
  /// access Amazon APIs.
  final String accessToken;

  /// The access token returned by the LWA login, which can be used to
  /// access Amazon APIs.
  final String authorizationCode;

  final String clientId;

  final String redirectURI;

  LwaAuthorizeResult.empty()
      : accessToken = null,
        authorizationCode = null,
        clientId = null,
        redirectURI = null;

  bool get isLoggedIn {
    return this.accessToken != null && this.accessToken.isNotEmpty;
  }

  /// Constructs instance from a [Map].
  LwaAuthorizeResult.fromMap(Map<String, dynamic> map)
      : accessToken = map['accessToken'],
        authorizationCode = map['authorizationCode'],
        clientId = map['clientId'],
        redirectURI = map['redirectURI'];

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

enum PROFILE_KEY { NAME, EMAIL, USER_ID, POSTAL_CODE }

const Map<PROFILE_KEY, String> ProfileKeyValues = {
  PROFILE_KEY.NAME: 'name',
  PROFILE_KEY.EMAIL: 'email',
  PROFILE_KEY.USER_ID: 'user_id',
  PROFILE_KEY.POSTAL_CODE: 'postal_code',
};

enum ERROR_TYPE {
  INVALID_TOKEN,
  INVALID_GRANT,
  INVALID_CLIENT,
  INVALID_SCOPE,
  UNAUTHORIZED_CLIENT,
  WEBVIEW_SSL,
  ACCESS_DENIED,
  COM,
  IO,
  BAD_PARAM,
  JSON,
  PARSE,
  SERVER_REPSONSE,
  DATA_STORAGE,
  THREAD,
  DCP_DMS,
  FORCE_UPDATE,
  REVOKE_AUTH,
  AUTH_DIALOG,
  BAD_API_PARAM,
  INIT,
  RESOURCES,
  DIRECTED_ID_NOT_FOUND,
  INVALID_API,
  SECURITY,
  UNKNOWN,
  REGISTRATION,
  MISSING_CODE_CHALLENGE,
  MISSING_TOKEN_FOR_REQUIRED_SCOPES,
}

const Map<ERROR_TYPE, int> ErrorTypeValues = {
  ERROR_TYPE.INVALID_TOKEN: 1,
  ERROR_TYPE.INVALID_GRANT: 2,
  ERROR_TYPE.INVALID_CLIENT: 3,
  ERROR_TYPE.INVALID_SCOPE: 4,
  ERROR_TYPE.UNAUTHORIZED_CLIENT: 5,
  ERROR_TYPE.WEBVIEW_SSL: 6,
  ERROR_TYPE.ACCESS_DENIED: 7,
  ERROR_TYPE.COM: 8,
  ERROR_TYPE.IO: 9,
  ERROR_TYPE.BAD_PARAM: 10,
  ERROR_TYPE.JSON: 11,
  ERROR_TYPE.PARSE: 12,
  ERROR_TYPE.SERVER_REPSONSE: 13,
  ERROR_TYPE.DATA_STORAGE: 14,
  ERROR_TYPE.THREAD: 15,
  ERROR_TYPE.DCP_DMS: 16,
  ERROR_TYPE.FORCE_UPDATE: 17,
  ERROR_TYPE.REVOKE_AUTH: 18,
  ERROR_TYPE.AUTH_DIALOG: 19,
  ERROR_TYPE.BAD_API_PARAM: 20,
  ERROR_TYPE.INIT: 21,
  ERROR_TYPE.RESOURCES: 22,
  ERROR_TYPE.DIRECTED_ID_NOT_FOUND: 23,
  ERROR_TYPE.INVALID_API: 24,
  ERROR_TYPE.SECURITY: 25,
  ERROR_TYPE.UNKNOWN: 26,
  ERROR_TYPE.REGISTRATION: 27,
  ERROR_TYPE.MISSING_CODE_CHALLENGE: 28,
  ERROR_TYPE.MISSING_TOKEN_FOR_REQUIRED_SCOPES: 29
};

/// The response from LwaUser.
class LwaUser {
  final Map<String, String> _userInfo;

  LwaUser._(this._userInfo);

  String get userId {
    return this._userInfo[ProfileKeyValues[PROFILE_KEY.USER_ID]];
  }

  String get userName {
    return this._userInfo[ProfileKeyValues[PROFILE_KEY.NAME]];
  }

  String get userEmail {
    return this._userInfo[ProfileKeyValues[PROFILE_KEY.EMAIL]];
  }

  String get userPostalCode {
    return this._userInfo[ProfileKeyValues[PROFILE_KEY.POSTAL_CODE]];
  }

  Map<String, String> get userInfo {
    return this._userInfo;
  }

  factory LwaUser.fromMap(Map<dynamic, dynamic> map) {
    LwaUser lwaUser = new LwaUser._(new Map<String, String>());
    map.forEach((k, v) {
      if (k == 'userInfo' || k == 'profileData') {
        if (v is Map<dynamic, dynamic>) {
          v.forEach((k1, v1) {
            lwaUser._userInfo[k1] = v1;
          });
        }
      }
    });
    return lwaUser;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LwaUser && _userInfo == other._userInfo;

  @override
  int get hashCode => _userInfo.hashCode;
}

class LoginWithAmazon {
  final List<Scope> scopes;

  /// The currently signed in account, or null if the user is signed out.
  LwaAuthorizeResult get currentAuth => _currentAuth;
  LwaAuthorizeResult _currentAuth;

  StreamController<LwaAuthorizeResult> _currentLwaAuthorizeController =
      StreamController<LwaAuthorizeResult>.broadcast();

  /// Subscribe to this stream to be notified when the current user changes.
  Stream<LwaAuthorizeResult> get onLwaAuthorizeChanged =>
      _currentLwaAuthorizeController.stream;

  LoginWithAmazon({this.scopes = const <Scope>[]});

  LwaAuthorizeResult _setCurrentAuth(LwaAuthorizeResult currentAuth) {
    if (currentAuth != _currentAuth) {
      _currentAuth = currentAuth;
      _currentLwaAuthorizeController.add(_currentAuth);
    }
    return _currentAuth;
  }

  /// The most recently scheduled method call.
  Future<void> _lastMethodCall;

  /// Returns a [Future] that completes with a success after [future], whether
  /// it completed with a value or an error.
  static Future<void> _waitFor(Future<void> future) {
    final Completer<void> completer = Completer<void>();
    future.whenComplete(completer.complete).catchError((dynamic _) {
      // Ignore if previous call completed with an error.
      // TODO: Should we log errors here, if debug or similar?
    });
    return completer.future;
  }

  Future<LwaAuthorizeResult> _callMethod(Function method) async {
    final dynamic response = await method();

    return _setCurrentAuth(
        response != null && response is LwaAuthorizeResult ? response : null);
  }

  /// Adds call to [method] in a queue for execution.
  ///
  /// At most one in flight call is allowed to prevent concurrent (out of order)
  /// updates to [currentAuth] and [onLwaAuthorizeChanged].
  ///
  /// The optional, named parameter [canSkipCall] lets the plugin know that the
  /// method call may be skipped, if there's already [_currentAuth] information.
  /// This is used from the [signIn] and [signInSilently] methods.
  Future<LwaAuthorizeResult> _addMethodCall(
    Function method, {
    bool canSkipCall = false,
  }) async {
    Future<LwaAuthorizeResult> response;
    if (_lastMethodCall == null) {
      response = _callMethod(method);
    } else {
      response = _lastMethodCall.then((_) {
        // If after the last completed call `currentUser` is not `null` and requested
        // method can be skipped (`canSkipCall`), re-use the same authenticated user
        // instead of making extra call to the native side.
        if (canSkipCall && _currentAuth != null && _currentAuth.isLoggedIn) {
          return _currentAuth;
        }
        return _callMethod(method);
      });
    }
    // Add the current response to the currently running Promise of all pending responses
    _lastMethodCall = _waitFor(response);
    return response;
  }

  Future<T> _deliverResult<T>(T result) {
    return Future.delayed(const Duration(milliseconds: 0), () => result);
  }

  /// Logs the user in with the requested scopes.
  ///
  /// Returns a [LwaAuthorizeResult] that contains relevant information about
  /// the current login status.
  Future<LwaAuthorizeResult> _signin() async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod(
      'signin',
      {'scopes': this.scopes.map((s) => s.toMap()).toList()},
    );
    return _deliverResult(
        LwaAuthorizeResult.fromMap(result.cast<String, dynamic>()));
  }

  Future<LwaAuthorizeResult> signIn() {
    final Future<LwaAuthorizeResult> result =
        _addMethodCall(_signin, canSkipCall: true);
    bool isCanceled(dynamic error) {
      ERROR_TYPE err = ERROR_TYPE.values
          .firstWhere((v) => v.toString() == 'ERROR_TYPE.' + error.code);
      return err != null;
    }

    return result;
  }

  Future<LwaAuthorizeResult> _signOut() async {
    await _channel.invokeMethod(
      'signout',
    );
    return _deliverResult(new LwaAuthorizeResult.empty());
  }

  /// Marks current user as being in the signed out state.
  Future<LwaAuthorizeResult> signOut() => _addMethodCall(_signOut);

  Future<LwaAuthorizeResult> _getToken() async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod(
      'getToken',
      {'scopes': this.scopes.map((s) => s.toMap()).toList()},
    );
    return LwaAuthorizeResult.fromMap(result.cast<String, dynamic>());
  }

  Future<LwaAuthorizeResult> signInSilently({
    bool suppressErrors = true,
  }) async {
    try {
      return await _addMethodCall(_getToken, canSkipCall: true);
    } catch (_) {
      if (suppressErrors) {
        return null;
      } else {
        rethrow;
      }
    }
  }

  Future<LwaUser> _getProfile() async {
    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('getProfile');
    return _deliverResult(LwaUser.fromMap(result.cast<String, dynamic>()));
  }

  Future<LwaUser> fetchUserProfile() {
    return _getProfile();
  }
}
