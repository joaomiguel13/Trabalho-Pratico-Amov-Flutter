import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:locatewiki_flutter/firebase_options.dart';
import 'package:locatewiki_flutter/widgets/locations.dart';

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void runAppWithFirebaseInitialization(Widget app) async {
  await initFirebase();
  runApp(app);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runAppWithFirebaseInitialization(const LocateWikiApp());
}

class LocateWikiApp extends StatelessWidget {
  const LocateWikiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locate Wiki',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const LocationsPage(),
    );
  }
}
