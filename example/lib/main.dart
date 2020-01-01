import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lwa/lwa.dart';

LoginWithAmazon _loginWithAmazon = LoginWithAmazon(
  scopes: <Scope>[ProfileScope.profile(), ProfileScope.postalCode()],
);

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LwaAuthorizeResult _lwaAuth;
  LwaUser _lwaUser;

  @override
  void initState() {
    super.initState();
    _loginWithAmazon.onLwaAuthorizeChanged.listen((LwaAuthorizeResult auth) {
      setState(() {
        _lwaAuth = auth;
      });
      _fetchUserProfile();
    });
    _loginWithAmazon.signInSilently();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _fetchUserProfile() async {
    if (_lwaAuth != null && _lwaAuth.isLoggedIn) {
      _lwaUser = await _loginWithAmazon.fetchUserProfile();
    } else {
      _lwaUser = null;
    }
    setState(() {
      _lwaUser = _lwaUser;
    });
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      await _loginWithAmazon.signIn();
    } catch (error) {
      if (error is PlatformException) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("${error.message}"),
        ));
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(error.toString()),
        ));
      }
    }
  }

  Future<void> _handleSignOut() => _loginWithAmazon.signOut();

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Sample Login with Amazon App',
            ),
          ),
          body: Builder(
            builder: (BuildContext _context) {
              return isLoading ? _loadingView : _bodyView(_context);
            },
          )),
    );
  }

  bool get isLoading {
    return false;
  }

  Widget get _loadingView {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  Widget _bodyView(BuildContext context) {
    return _lwaUser != null && _lwaAuth.isLoggedIn
        ? _loggedInWidgets()
        : _loggedOutWidgets(context);
  }

  Widget _loggedInWidgets() {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Container(
        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: Align(
            alignment: Alignment.topRight,
            child: FlatButton(
              child: Text('Logout'),
              onPressed: _handleSignOut,
            )),
      ),
      Expanded(
        child: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              "Welcome, ${_lwaUser.userName}!\nYour email is ${_lwaUser.userEmail}\nYour zipCode is ${_lwaUser.userPostalCode}\n",
              maxLines: 6,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _loggedOutWidgets(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Expanded(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              'Welcome to Login with Amazon!\nIf this is your first time logging in, you will be asked to give permission for this application to access your profile data.',
              maxLines: 6,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
        child: LwaButton(onPressed: () => _handleSignIn(context)),
      ),
    ]);
  }
}
