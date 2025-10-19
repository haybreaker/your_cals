import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:your_cals/data/databases/interfaces/database_helper_interface.dart';
import 'package:your_cals/data/databases/sqlite3/sqlite.dart';
import 'package:your_cals/data/providers/app_settings_provider.dart';
import 'package:your_cals/data/providers/food_db_provider.dart';
import 'package:your_cals/data/providers/food_entries_provider.dart';
import 'package:your_cals/data/providers/user_provider.dart';
import 'package:your_cals/data/settings/app_settings.dart';
import 'package:your_cals/ui/pages/main_page/main_page.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Set up our app settings and providers
  await AppSettings.init();

  final DatabaseHelperInterface db = SqliteDatabaseHelper();
  await db.init();

  final FoodDatabaseProvider foodDbProvider = FoodDatabaseProvider(dbHelper: db);
  foodDbProvider.initialize();

  // Start the application
  FlutterNativeSplash.remove();
  runApp(YourCals(db, foodDbProvider));
}

class YourCals extends StatelessWidget {
  final DatabaseHelperInterface db;
  final FoodDatabaseProvider foodDb;
  const YourCals(this.db, this.foodDb, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => foodDb),
        ChangeNotifierProvider(create: (context) => FoodEntriesProvider(db)),
      ],
      builder: (context, child) =>
          MaterialApp(title: 'Your Cals', theme: context.watch<AppSettingsProvider>().theme, home: const MainPage()),
    );
  }
}
