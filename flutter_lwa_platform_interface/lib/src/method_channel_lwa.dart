part of '../flutter_lwa_platform_interface.dart';

/// An implementation of [LwaPlatform] that uses method channels.
class MethodChannelLwa extends LwaPlatform {
  /// This is only exposed for test purposes. It shouldn't be used by clients of
  /// the plugin as it may break or change at any time.
  @visibleForTesting
  MethodChannel channel = const MethodChannel('com.github.ayvazj/flutter_lwa');
  LwaAuthorizeResult _currentAuth = LwaAuthorizeResult.empty();

  final StreamController<LwaAuthorizeResult> _currentLwaAuthorizeController =
      StreamController<LwaAuthorizeResult>.broadcast();

  MethodChannelLwa() : super();

  @override
  Future<void> init(
      {List<Scope> scopes = const <Scope>[],
      GrantType? grantType,
      ProofKeyParameters? proofKeyParameters}) async {
    this.scopes = scopes;
    this.grantType = grantType;
    this.proofKeyParameters = proofKeyParameters;
  }

  @override
  LwaAuthorizeResult getCurrentAuth() {
    return _currentAuth;
  }

  @override
  Stream<LwaAuthorizeResult> getOnLwaAuthorizeChangedStream() {
    return _currentLwaAuthorizeController.stream;
  }

  @override
  Future<LwaAuthorizeResult> signIn() async {
    final result = _addMethodCall(_signin, canSkipCall: true);
    return result;
  }

  @override
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

  @override
  Future<LwaAuthorizeResult> signOut() async => _addMethodCall(_signOut);

  @override
  Future<LwaUser> fetchUserProfile() async {
    return _getProfile();
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
  /// updates to [getCurrentAuth] and [getOnLwaAuthorizeChangedStream].
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
    var arguments = <String, dynamic>{SCOPES_ARGUMENT: scopes.map((s) => s.toMap()).toList()};
    if (grantType != null) {
      arguments.putIfAbsent(GRANT_TYPE_ARGUMENT, () => '${grantType?.asString()}');
    }
    if (proofKeyParameters != null) {
      arguments.putIfAbsent(PROOFKEY_PARAMETERS_ARGUMENT, () => {
        CODE_CHALLENGE_ARGUMENT: proofKeyParameters?.codeChallenge ?? "",
        CODE_CHALLENGE_METHOD_ARGUMENT: proofKeyParameters?.codeChallengeMethod ?? "",
      });
    }
    final result = await channel.invokeMethod(
      SIGNIN_ARGUMENT,
      arguments,
    );
    if (result != null && result is Map) {
      return _deliverResult(
          LwaAuthorizeResult.fromMap(result.cast<String, dynamic>()));
    } else {
      return _deliverResult(LwaAuthorizeResult.empty());
    }
  }

  Future<LwaAuthorizeResult> _signOut() async {
    await channel.invokeMethod(
      SIGNOUT_ARGUMENT,
    );
    return _deliverResult(LwaAuthorizeResult.empty());
  }

  Future<LwaAuthorizeResult> _getToken() async {
    final result = await channel.invokeMethod(
      GETTOKEN_ARGUMENT,
      {SCOPES_ARGUMENT: scopes.map((s) => s.toMap()).toList()},
    );
    if (result != null && result is Map) {
      return _deliverResult(
          LwaAuthorizeResult.fromMap(result.cast<String, dynamic>()));
    } else {
      return _deliverResult(LwaAuthorizeResult.empty());
    }
  }

  Future<LwaUser> _getProfile() async {
    final result = await channel.invokeMethod(GETPROFILE_ARGUMENT);
    if (result != null && result is Map) {
      return _deliverResult(LwaUser.fromMap(Map<String, dynamic>.from(result)));
    } else {
      return _deliverResult(LwaUser.fromMap({}));
    }
  }
}
