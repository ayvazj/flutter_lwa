import 'package:flutter/services.dart';
import 'package:flutter_lwa/lwa.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('com.github.ayvazj/flutter_lwa');

  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> kDefaultResponses = <String, dynamic>{
    'getToken': {
      'accessToken': 'accessToken',
      'authorizationCode': 'authorizationCode',
      'clientId': 'clientId',
      'redirectURI': 'redirectURI',
    },
    'signin': {
      'accessToken': 'accessToken',
      'authorizationCode': 'authorizationCode',
      'clientId': 'clientId',
      'redirectURI': 'redirectURI',
    },
    'signout': {
      'accessToken': '',
      'authorizationCode': '',
      'clientId': '',
      'redirectURI': '',
    },
    'getProfile': {
      'profileData': {
        'name': 'name',
        'email': 'email',
        'user_id': 'user_id',
        'postal_code': 'postal_code',
      },
    },
  };

  final List<MethodCall> log = <MethodCall>[];
  Map<String, dynamic> responses;
  late LoginWithAmazon loginWithAmazon;

  setUp(() {
    responses = Map<String, dynamic>.from(kDefaultResponses);
    channel.setMockMethodCallHandler((MethodCall methodCall) {
      log.add(methodCall);
      final dynamic response = responses[methodCall.method];
      if (response != null && response is Exception) {
        return Future<dynamic>.error('$response');
      }
      return Future<dynamic>.value(response);
    });

    loginWithAmazon = LoginWithAmazon(
      scopes: <Scope>[ProfileScope.profile(), ProfileScope.postalCode()],
    );
    log.clear();
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('signInSilently', () async {
    LwaAuthorizeResult authResult = await loginWithAmazon.signInSilently();
    expect(authResult, isNotNull);
    expect(authResult.isLoggedIn, true);
    expect(
      log,
      <Matcher>[
        isMethodCall('getToken', arguments: <String, dynamic>{
          'scopes': <dynamic>[
            ProfileScope.profile().toMap(),
            ProfileScope.postalCode().toMap(),
          ],
        }),
      ],
    );
  });

  test('signin', () async {
    LwaAuthorizeResult authResult = await loginWithAmazon.signIn();
    expect(authResult, isNotNull);
    expect(authResult.isLoggedIn, true);
    expect(
      log,
      <Matcher>[
        isMethodCall('signin', arguments: <String, dynamic>{
          'scopes': <dynamic>[
            ProfileScope.profile().toMap(),
            ProfileScope.postalCode().toMap(),
          ],
        }),
      ],
    );
  });

  test('signout', () async {
    LwaAuthorizeResult authResult = await loginWithAmazon.signOut();
    expect(authResult, isNotNull);
    expect(authResult.isLoggedIn, false);
    expect(
      log,
      <Matcher>[
        isMethodCall('signout', arguments: null),
      ],
    );
  });

  test('fetchUserProfile', () async {
    LwaUser userProfile = await loginWithAmazon.fetchUserProfile();
    expect(userProfile, isNotNull);
    expect(userProfile.userId, isNotNull);
    expect(userProfile.userEmail, isNotNull);
    expect(userProfile.userName, isNotNull);
    expect(userProfile.userPostalCode, isNotNull);
    expect(
      log,
      <Matcher>[
        isMethodCall('getProfile', arguments: null),
      ],
    );
  });
}
