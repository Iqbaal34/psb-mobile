import 'package:flutter/material.dart';
import 'package:inventaris_app/loginpage.dart';
import 'package:inventaris_app/mysql_utils.dart';

void main() {
  MysqlUtils.initConnection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => const Loginpage(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.light,
        ),
      ),
      home: Loginpage(),
    );
  }
}
