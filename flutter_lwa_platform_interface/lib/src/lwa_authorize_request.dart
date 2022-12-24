part of '../flutter_lwa_platform_interface.dart';

enum GrantType {
  ACCESS_TOKEN,
  AUTHORIZATION_CODE,
}

extension GrantTypeAsString on GrantType {
  String asString() {
    return toString()
        .split('.')
        .last;
  }
}

class ProofKeyParameters {
  final String codeChallenge;
  final String codeChallengeMethod;

  ProofKeyParameters(this.codeChallenge, this.codeChallengeMethod);
}
