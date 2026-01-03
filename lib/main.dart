import 'package:flutter/material.dart';
import 'package:zinus_connect/router.dart';

void main() {
  runApp(const ZinusConnectApp());
}

class ZinusConnectApp extends StatelessWidget {
  const ZinusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Zinus Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    );
  }
}
