import 'package:flutter/material.dart';

import 'package:cinema_inventory/apptheme.dart';
import 'package:cinema_inventory/homescreen.dart';

class CinemaInventoryApp extends StatelessWidget {
  const CinemaInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cinema Inventory',
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
