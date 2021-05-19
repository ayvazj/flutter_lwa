part of '../flutter_lwa_platform_interface.dart';

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
