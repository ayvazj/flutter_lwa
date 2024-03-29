import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lwa/lwa.dart';
import 'package:flutter_lwa_platform_interface/flutter_lwa_platform_interface.dart';

const LOGIN_OPTIONS_MAP = {
  'LWA': 'Login with Amazon (LWA)',
  'AVS': 'Alexa Voice Service (AVS)'
};

LoginWithAmazon _loginWithAmazon = LoginWithAmazon(
  scopes: <Scope>[ProfileScope.profile(), ProfileScope.postalCode()],
);

const PRODUCT_DSN = "A17EGG3HZXVDFE";
const PRODUCT_ID = "TEST_PRODUCT_1";

LoginWithAmazon _loginWithAmazonAVS = LoginWithAmazon(
  scopes: <Scope>[
    ProfileScope.profile(),
    ProfileScope.postalCode(),
    ScopeFactory.scopeNamed("alexa:voice_service:pre_auth"),
    ScopeFactory.scopeNamedWithData("alexa:all", {
      "productInstanceAttributes": {
        "deviceSerialNumber": PRODUCT_DSN,
      },
      "productID": PRODUCT_ID,
    })
  ],
);

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LwaAuthorizeResult _lwaAuth = LwaAuthorizeResult.empty();
  LwaUser _lwaUser = LwaUser.empty();
  String loginOption = 'LWA';

  @override
  void initState() {
    super.initState();
    _loginWithAmazon.onLwaAuthorizeChanged.listen((LwaAuthorizeResult auth) {
      setState(() {
        _lwaAuth = auth;
        loginOption = 'LWA';
      });
      _fetchUserProfile();
    });
    _loginWithAmazon.signInSilently();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _fetchUserProfile() async {
    if (_lwaAuth.isLoggedIn) {
      _lwaUser = await _loginWithAmazon.fetchUserProfile();
    } else {
      _lwaUser = LwaUser.empty();
    }
    setState(() {
      _lwaUser = _lwaUser;
    });
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      if (loginOption == 'AVS') {
        await _loginWithAmazonAVS.signIn();
      } else {
        await _loginWithAmazon.signIn();
      }
    } catch (error) {
      if (error is PlatformException) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${error.message}'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _bodyView(BuildContext context) {
    return _lwaAuth.isLoggedIn
        ? _loggedInWidgets()
        : _loggedOutWidgets(context);
  }

  Widget _loggedInWidgets() {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: _handleSignOut,
              child: const Text('Logout'),
            )),
      ),
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              'Welcome, ${_lwaUser.userName}!\nYour email is ${_lwaUser.userEmail}\nYour zipCode is ${_lwaUser.userPostalCode}\n',
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
      const Expanded(
        child: Center(
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
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: DropdownButtonFormField<String>(
          value: loginOption,
          decoration: const InputDecoration(
            labelText: 'Login Option',
            border: OutlineInputBorder(),
          ),
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              loginOption = value!;
            });
          },
          items: LOGIN_OPTIONS_MAP.keys
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(LOGIN_OPTIONS_MAP[value] ?? ''),
            );
          }).toList(),
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
        child: LwaButton(onPressed: () => _handleSignIn(context)),
      ),
    ]);
  }
}
