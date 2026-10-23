import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sovereign/core/errors/failure.dart';
import 'package:sovereign/core/errors/guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('guard', () {
    test('passes values through successfully', () async {
      final result = await guard(() async => 'hello');
      expect(result, 'hello');
    });

    test('maps SocketException to NetworkFailure with non-empty message', () async {
      expect(
        () => guard(() async {
          throw const SocketException('Failed host lookup');
        }),
        throwsA(isA<NetworkFailure>().having(
          (f) => f.message,
          'message',
          isNotEmpty,
        )),
      );
    });

    test('maps ClientException to NetworkFailure with non-empty message', () async {
      expect(
        () => guard(() async {
          throw http.ClientException('Connection reset');
        }),
        throwsA(isA<NetworkFailure>().having(
          (f) => f.message,
          'message',
          isNotEmpty,
        )),
      );
    });

    test('maps AuthException to AuthFailure with message', () async {
      expect(
        () => guard(() async {
          throw const AuthException('Invalid login credentials');
        }),
        throwsA(isA<AuthFailure>().having(
          (f) => f.message,
          'message',
          'Invalid login credentials',
        )),
      );
    });

    test('maps PostgrestException PGRST116 to NotFoundFailure', () async {
      expect(
        () => guard(() async {
          throw const PostgrestException(
            message: 'Results contain 0 rows',
            code: 'PGRST116',
          );
        }),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('rethrows existing Failure untouched', () async {
      expect(
        () => guard(() async {
          throw const UnknownFailure('custom failure');
        }),
        throwsA(isA<UnknownFailure>().having(
          (f) => f.message,
          'message',
          'custom failure',
        )),
      );
    });
  });
}
