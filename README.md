# flutter_lwa

[![pub package](https://img.shields.io/pub/v/flutter_lwa.svg)](https://pub.dartlang.org/packages/flutter_lwa)
[![Build Status](https://travis-ci.org/ayvazj/flutter_lwa.svg?branch=master)](https://travis-ci.org/ayvazj/flutter_lwa) 
[![Coverage Status](https://coveralls.io/repos/github/ayvazj/flutter_lwa/badge.svg)](https://coveralls.io/github/ayvazj/flutter_lwa)

A Flutter plugin for using [Login with Amazon](https://developer.amazon.com/apps-and-games/login-with-amazon) on Android and iOS.

## Installation

In addition to adding a pubspec dependency, this plugin requires
[Login with Amazon](https://developer.amazon.com/apps-and-games/login-with-amazon) setup which
requires modification of the native Android and iOS code of your flutter application.

### Add a dependency to your pubspec.yml file

See the [installation instructions on pub](https://pub.dartlang.org/packages/flutter_lwa#-installing-tab-).


### [Login with Amazon](https://developer.amazon.com/apps-and-games/login-with-amazon)

Register for [Login with Amazon](https://developer.amazon.com/apps-and-games/login-with-amazon) 
access and create API keys for Android and iOS as described in the documentation.

* [Android](https://developer.amazon.com/docs/login-with-amazon/register-android.html)
* [iOS](https://developer.amazon.com/docs/login-with-amazon/register-ios.html)


### Android

1. Create a [Login with Amazon](https://developer.amazon.com/apps-and-games/login-with-amazon)
API key for [Android](https://developer.amazon.com/docs/login-with-amazon/register-android.html).

1. Create a text file located at `{project_root}/android/app/main/assets/api_key.txt`

1. Copy-paste the contents of the API key from the [Login with Amazon](https://developer.amazon.com/apps-and-games/login-with-amazon)
console into the file `{project_root}/android/app/main/assets/api_key.txt`

**Done!**

### iOS

1. Create a [Login with Amazon](https://developer.amazon.com/apps-and-games/login-with-amazon)
API key for [iOS](https://developer.amazon.com/docs/login-with-amazon/register-ios.html).

1. Add the APIKey key to the iOS properties file located at `{project_root}/ios/Runner/Info.plist`.
**The {api_key} should be the API key copy-pasted from the [Login with Amazon](https://developer.amazon.com/apps-and-games/login-with-amazon)
console.**

```xml
	<key>APIKey</key>
	<string>{api_key}</string>
```

1. Add the CFBundleURLTypes key to the iOS properties file located at `{project_root}/ios/Runner/Info.plist`.
**The {bundle_id} should be the bundle identifier of your application.** (Example of a bundle id: com.github.ayvazj.example)

```xml
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string>{bundle_id}</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>amzn-{bundle_id}</string>
			</array>
		</dict>
	</array>
```

1. Update `{project_root}/ios/Runner/AppDelegate.m` to add the 
`#import <LoginWithAmazon/LoginWithAmazon.h>` import statement as well as the
`(BOOL)application:(UIApplication *)application openURL:(NSURL *) url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options` 
method.

```java

#import <LoginWithAmazon/LoginWithAmazon.h>

@implementation AppDelegate

...

- (BOOL)application:(UIApplication *)application openURL:(NSURL *) url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    return [AMZNAuthorizationManager handleOpenURL:url
                                 sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
}

...

@end
```
   


A sample of a complete Info.plist file can be found [here](https://github.com/ayvazj/flutter_lwa/blob/master/example/ios/Runner/Info.plist).

Done!

## How do I use it?

The plugin follows the same patterns as the Google Signin API to make integration simple.  For a
complete sample see the example application.

```dart
import 'package:flutter_lwa/lwa.dart';

LoginWithAmazon _loginWithAmazon = LoginWithAmazon(
  scopes: <Scope>[ProfileScope.profile(), ProfileScope.postalCode()],
);

class _MyAppState extends State<MyApp> {
  LwaAuthorizeResult _lwaAuth;

  @override
  void initState() {
    super.initState();
    _loginWithAmazon.onLwaAuthorizeChanged.listen((LwaAuthorizeResult auth) {
      setState(() {
        _lwaAuth = auth;
      });
    });
    _loginWithAmazon.signInSilently();
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      await _loginWithAmazon.signin();
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
}

```
