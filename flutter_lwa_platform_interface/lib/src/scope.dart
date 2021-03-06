part of '../flutter_lwa_platform_interface.dart';

abstract class Scope {
  String getName();

  Map<String, dynamic>? getScopeData();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'name': getName(), 'scopeData': getScopeData()};
  }
}

class GenericScope extends Scope {
  final String _name;
  final Map<String, Object>? _scopeData;

  GenericScope._(this._name, this._scopeData);

  factory GenericScope(String name) {
    return GenericScope._(name, null);
  }

  @override
  String getName() {
    return _name;
  }

  @override
  Map<String, dynamic>? getScopeData() {
    return _scopeData;
  }

  @override
  int get hashCode => _name.hashCode ^ _scopeData.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenericScope &&
          _name == other._name &&
          _scopeData == other._scopeData;
}

class ScopeFactory {
  static Scope scopeNamed(String name) {
    return GenericScope(name);
  }

  static Scope scopeNamedWithData(String name, Map<String, Object> scopeData) {
    return GenericScope._(name, scopeData);
  }
}

class ProfileScope {
  static Scope profile() {
    return ScopeFactory.scopeNamed('profile');
  }

  static Scope userId() {
    return ScopeFactory.scopeNamed('profile:user_id');
  }

  static Scope postalCode() {
    return ScopeFactory.scopeNamed('postal_code');
  }
}
