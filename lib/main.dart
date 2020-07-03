/// the layout overflows if aspect ratio is squarer than 16X9
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'folder_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      theme: ThemeData.dark(), // ThemeData(primarySwatch: Colors.blueGrey),
      initialRoute: '/',
      routes: {
        '/': (context) => FolderScreen(),
      },
    );
  }
}
