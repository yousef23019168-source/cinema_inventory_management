import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:cinema_inventory/apptheme.dart';
import 'package:cinema_inventory/homescreen.dart';

class CinemaInventoryApp extends StatelessWidget {
  const CinemaInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'إدارة معدات الإنتاج',
      theme: AppTheme.light,
      // الاتجاه RTL على مستوى التطبيق كله
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}
