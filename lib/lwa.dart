import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

part 'constants.dart';

part 'scope.dart';

part 'widgets.dart';

const package_name = 'flutter_lwa';
final log = Logger(package_name);

T? cast<T>(x) => x is T ? x : null;

void initLogging() {
  // disable hierarchical logger
  hierarchicalLoggingEnabled = false;
  Logger.root.level = Level.INFO;
  // skip logging stack trace below the SEVERE level.
  recordStackTraceAtLevel = Level.SEVERE;
  assert(() {
    recordStackTraceAtLevel = Level.WARNING;
    // print all logs on debug build.
    Logger.root.level = Level.ALL;
    return true;
  }());
  Logger.root.onRecord.listen((event) {
    developer.log(
      event.message,
      time: event.time,
      sequenceNumber: event.sequenceNumber,
      level: event.level.value,
      name: event.loggerName,
      zone: event.zone,
      error: event.error,
      stackTrace: event.stackTrace,
    );
  });
}

const MethodChannel _channel = MethodChannel('com.github.ayvazj/$package_name');

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

/// The response from LwaUser.
class LwaUser {
  final Map<String, String> _userInfo;

  LwaUser._(this._userInfo);

  String? get userId {
    return _userInfo[ProfileKeyValues[PROFILE_KEY.USER_ID]!];
  }

  String? get userName {
    return _userInfo[ProfileKeyValues[PROFILE_KEY.NAME]!];
  }

  String? get userEmail {
    return _userInfo[ProfileKeyValues[PROFILE_KEY.EMAIL]!];
  }

  String? get userPostalCode {
    return _userInfo[ProfileKeyValues[PROFILE_KEY.POSTAL_CODE]!];
  }

  Map<String, String> get userInfo {
    return _userInfo;
  }

  factory LwaUser.fromMap(Map<dynamic, dynamic> m) {
    final lwaUser = LwaUser._(<String, String>{});
    m.forEach((k, v) {
      if (k == 'userInfo' || k == 'profileData') {
        if (v is Map) {
          final vmap = Map<String, String>.from(v);
          vmap.forEach((k1, v1) {
            lwaUser._userInfo[k1] = v1;
          });
        }
      }
    });
    return lwaUser;
  }

  LwaUser.empty() : _userInfo = <String, String>{};

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
  LwaAuthorizeResult _currentAuth = LwaAuthorizeResult.empty();

  final StreamController<LwaAuthorizeResult> _currentLwaAuthorizeController =
      StreamController<LwaAuthorizeResult>.broadcast();

  /// Subscribe to this stream to be notified when the current user changes.
  Stream<LwaAuthorizeResult> get onLwaAuthorizeChanged =>
      _currentLwaAuthorizeController.stream;

  LoginWithAmazon({this.scopes = const <Scope>[]}) {
    initLogging();
  }

  LwaAuthorizeResult _setCurrentAuth(LwaAuthorizeResult currentAuth) {
    if (currentAuth != _currentAuth) {
      _currentAuth = currentAuth;
      _currentLwaAuthorizeController.add(_currentAuth);
    }
    return _currentAuth;
  }

  /// The most recently scheduled method call.
  Future<void>? _lastMethodCall;

  /// Returns a [Future] that completes with a success after [future], whether
  /// it completed with a value or an error.
  static Future<void> _waitFor(Future<void> future) {
    final completer = Completer<void>();
    future.whenComplete(completer.complete).catchError((dynamic _) {
      // Ignore if previous call completed with an error.
      // TODO: Should we log errors here, if debug or similar?
    });
    return completer.future;
  }

  Future<LwaAuthorizeResult> _callMethod(Function method) async {
    final dynamic response = await method();
    if (response != null && response is LwaAuthorizeResult) {
      _setCurrentAuth(response);
      return response;
    } else {
      return LwaAuthorizeResult.empty();
    }
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
    final lmc = _lastMethodCall;
    if (lmc == null) {
      response = _callMethod(method);
    } else {
      response = lmc.then((_) {
        // re-use the same authenticated user
        // instead of making extra call to the native side.
        if (canSkipCall && _currentAuth.isLoggedIn) {
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
    final result = await _channel.invokeMethod(
      'signin',
      {'scopes': scopes.map((s) => s.toMap()).toList()},
    );
    if (result != null && result is Map) {
      return _deliverResult(
          LwaAuthorizeResult.fromMap(result.cast<String, dynamic>()));
    } else {
      return _deliverResult(LwaAuthorizeResult.empty());
    }
  }

  Future<LwaAuthorizeResult> signIn() {
    final result = _addMethodCall(_signin, canSkipCall: true);
    return result;
  }

  Future<LwaAuthorizeResult> _signOut() async {
    await _channel.invokeMethod(
      'signout',
    );
    return _deliverResult(LwaAuthorizeResult.empty());
  }

  /// Marks current user as being in the signed out state.
  Future<LwaAuthorizeResult> signOut() => _addMethodCall(_signOut);

  Future<LwaAuthorizeResult> _getToken() async {
    final result = await _channel.invokeMethod(
      'getToken',
      {'scopes': scopes.map((s) => s.toMap()).toList()},
    );
    if (result != null && result is Map) {
      return _deliverResult(
          LwaAuthorizeResult.fromMap(result.cast<String, dynamic>()));
    } else {
      return _deliverResult(LwaAuthorizeResult.empty());
    }
  }

  Future<LwaAuthorizeResult> signInSilently({
    bool suppressErrors = true,
  }) async {
    try {
      return await _addMethodCall(_getToken, canSkipCall: true);
    } catch (err) {
      if (suppressErrors) {
        log.warning('$err');
        return _deliverResult(LwaAuthorizeResult.empty());
      } else {
        rethrow;
      }
    }
  }

  Future<LwaUser> _getProfile() async {
    final result = await _channel.invokeMethod('getProfile');
    if (result != null && result is Map) {
      return _deliverResult(LwaUser.fromMap(Map<String, dynamic>.from(result)));
    } else {
      return _deliverResult(LwaUser.fromMap({}));
    }
  }

  Future<LwaUser> fetchUserProfile() {
    return _getProfile();
  }
}
