import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/datasources/cache_service.dart';
import 'data/models/daily_digest_model.dart';
import 'data/models/news_model.dart';
import 'data/models/suggestion_model.dart';
import 'presentation/app.dart';
import 'presentation/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize French locale for date formatting
  await initializeDateFormatting('fr_FR', null);

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(NewsModelAdapter());
  Hive.registerAdapter(SuggestionModelAdapter());
  Hive.registerAdapter(DailyDigestModelAdapter());

  // Initialize CacheService
  final cacheService = CacheService();
  await cacheService.init();

  runApp(
    ProviderScope(
      overrides: [
        // Provide the initialized CacheService instance
        cacheServiceProvider.overrideWithValue(cacheService),
      ],
      child: const FinanceDailyDigestApp(),
    ),
  );
}
