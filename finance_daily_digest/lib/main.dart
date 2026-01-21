import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/models/daily_digest_model.dart';
import 'data/models/news_model.dart';
import 'data/models/suggestion_model.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(NewsModelAdapter());
  Hive.registerAdapter(SuggestionModelAdapter());
  Hive.registerAdapter(DailyDigestModelAdapter());

  runApp(
    const ProviderScope(
      child: FinanceDailyDigestApp(),
    ),
  );
}
