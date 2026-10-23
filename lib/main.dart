import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/app.dart';
import 'package:sovereign/core/config/env.dart';
import 'package:sovereign/core/theme/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: Env.supabaseAnonKey,
    );
    runApp(const ProviderScope(child: SovereignApp()));
  } else {
    runApp(const SetupRequiredApp());
  }
}

/// Fallback screen when --dart-define flags are missing.
class SetupRequiredApp extends StatelessWidget {
  const SetupRequiredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sovereign Setup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: SovereignColors.black,
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                color: SovereignColors.surfaceDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.settings_suggest,
                            color: SovereignColors.rossoCorsa,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'CONFIGURATION REQUIRED',
                            style: TextStyle(
                              color: SovereignColors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Sovereign requires Supabase credentials passed via dart-define flags at startup:',
                        style: TextStyle(color: SovereignColors.white, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: SovereignColors.black,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          'flutter run \\\n'
                          '  --dart-define=SUPABASE_URL=https://xyz.supabase.co \\\n'
                          '  --dart-define=SUPABASE_ANON_KEY=eyJh...',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: SovereignColors.racingYellow,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
