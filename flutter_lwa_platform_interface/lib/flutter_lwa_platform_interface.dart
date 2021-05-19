import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'src/constants.dart';

part 'src/lwa_authorize_result.dart';

part 'src/lwa_user.dart';

part 'src/method_channel_lwa.dart';

part 'src/scope.dart';

const package_name = 'flutter_lwa';
final log = Logger('lwa_platform_interface');

/// The interface that implementations of flutter_lwa must implement.
///
/// Platform implementations should extend this class rather than implement it as `flutter_lwa`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [LwaPlatform] methods.
abstract class LwaPlatform extends PlatformInterface {
  List<Scope> scopes = const <Scope>[];
  static final Object _token = Object();

  LwaPlatform() : super(token: _token) {
    _initLogging();
  }

  /// The default instance of [LwaPlatform] to use.
  ///
  /// Defaults to [MethodChannelLwa].
  static LwaPlatform get instance => _instance;
  static LwaPlatform _instance = MethodChannelLwa();

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [LwaPlatform] when they register themselves.
  static set instance(LwaPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> init({List<Scope> scopes = const <Scope>[]}) async {
    throw UnimplementedError('init() has not been implemented.');
  }

  LwaAuthorizeResult getCurrentAuth() {
    throw UnimplementedError('getCurrentAuth() has not been implemented.');
  }

  /// Subscribe to this stream to be notified when the current user changes.
  Stream<LwaAuthorizeResult> getOnLwaAuthorizeChangedStream() {
    throw UnimplementedError(
        'onLwaAuthorizeChanged() has not been implemented.');
  }

  Future<LwaAuthorizeResult> signIn() async {
    throw UnimplementedError('signIn() has not been implemented.');
  }

  /// Marks current user as being in the signed out state.
  Future<LwaAuthorizeResult> signOut() async {
    throw UnimplementedError('signOut() has not been implemented.');
  }

  Future<LwaAuthorizeResult> signInSilently(
      {bool suppressErrors = true}) async {
    throw UnimplementedError('signInSilently() has not been implemented.');
  }

  Future<LwaUser> fetchUserProfile() async {
    throw UnimplementedError('fetchUserProfile() has not been implemented.');
  }

  static void _initLogging() {
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
}
