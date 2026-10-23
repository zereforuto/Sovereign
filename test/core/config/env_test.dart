import 'package:flutter_test/flutter_test.dart';
import 'package:sovereign/core/config/env.dart';

void main() {
  group('Env', () {
    test('isConfigured is false with no dart-defines', () {
      expect(Env.isConfigured, isFalse);
      expect(Env.supabaseUrl, isEmpty);
      expect(Env.supabaseAnonKey, isEmpty);
    });
  });
}
