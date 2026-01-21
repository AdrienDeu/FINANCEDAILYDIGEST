import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // TODO: Register Hive adapters here when models are created
  // Hive.registerAdapter(NewsAdapter());
  // Hive.registerAdapter(SuggestionAdapter());
  // Hive.registerAdapter(DailyDigestAdapter());

  runApp(
    const ProviderScope(
      child: FinanceDailyDigestApp(),
    ),
  );
}
