import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_example/config.dart';
import 'package:flutter_bluetooth_serial_example/home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:folly_fields/folly_fields.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FollyFields.start(Config());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Home(),
    );
  }
}
