import 'package:flutter/services.dart';
import 'package:flutter_lwa_platform_interface/flutter_lwa_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final kDefaultResponses = <String, dynamic>{
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

  final log = <MethodCall>[];
  Map<String, dynamic> responses;
  late MethodChannelLwa loginWithAmazon;
  final scopes = <Scope>[ProfileScope.profile(), ProfileScope.postalCode()];

  setUp(() {
    responses = Map<String, dynamic>.from(kDefaultResponses);

    loginWithAmazon = MethodChannelLwa();
    final channel = loginWithAmazon.channel;
    loginWithAmazon.init(scopes: scopes);

    channel.setMockMethodCallHandler((MethodCall methodCall) {
      log.add(methodCall);
      final dynamic response = responses[methodCall.method];
      if (response != null && response is Exception) {
        return Future<dynamic>.error('$response');
      }
      return Future<dynamic>.value(response);
    });

    log.clear();
  });

  tearDown(() {
    loginWithAmazon.channel.setMockMethodCallHandler(null);
  });

  test('signInSilently', () async {
    final authResult = await loginWithAmazon.signInSilently();
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
    final authResult = await loginWithAmazon.signIn();
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
    final authResult = await loginWithAmazon.signOut();
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
    final userProfile = await loginWithAmazon.fetchUserProfile();
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
