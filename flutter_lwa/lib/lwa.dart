import 'package:flutter/material.dart';
import 'package:flutter_lwa_platform_interface/flutter_lwa_platform_interface.dart';

part 'widgets.dart';

class LoginWithAmazon {
  final List<Scope> scopes;

  LoginWithAmazon({this.scopes = const <Scope>[]});

  Future<LwaAuthorizeResult> get currentAuth async {
    await _ensureInitialized();
    return LwaPlatform.instance.getCurrentAuth();
  }

  Stream<LwaAuthorizeResult> get onLwaAuthorizeChanged {
    _ensureInitialized();
    return LwaPlatform.instance.getOnLwaAuthorizeChangedStream();
  }

  Future<LwaUser> fetchUserProfile() async {
    await _ensureInitialized();
    return LwaPlatform.instance.fetchUserProfile();
  }

  Future<LwaAuthorizeResult> signIn() async {
    await _ensureInitialized();
    return LwaPlatform.instance.signIn();
  }

  Future<LwaAuthorizeResult> signInSilently(
      {bool suppressErrors = true}) async {
    await _ensureInitialized();
    return LwaPlatform.instance.signInSilently(suppressErrors: suppressErrors);
  }

  Future<LwaAuthorizeResult> signOut() async {
    await _ensureInitialized();
    return LwaPlatform.instance.signOut();
  }

  Future<void> _ensureInitialized() async {
    await LwaPlatform.instance.init(scopes: scopes);
  }
}
