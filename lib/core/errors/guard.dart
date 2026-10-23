import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sovereign/core/errors/failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps asynchronous operations and maps known exceptions to typed [Failure]s.
Future<T> guard<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on Failure {
    rethrow;
  } on SocketException {
    throw const NetworkFailure(
      'Unable to connect to the server. Please check your internet connection.',
    );
  } on http.ClientException {
    throw const NetworkFailure(
      'Network request failed. Please check your internet connection and retry.',
    );
  } on AuthException catch (e) {
    throw AuthFailure(e.message);
  } on PostgrestException catch (e) {
    if (e.code == 'PGRST116') {
      throw const NotFoundFailure('The requested record was not found.');
    }
    throw UnknownFailure(e.message);
  } catch (e) {
    throw UnknownFailure(e.toString());
  }
}
