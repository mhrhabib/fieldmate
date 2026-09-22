import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'screens/job_list_screen.dart';

void main() {
  runApp(const ApplianceRepairApp());
}

class ApplianceRepairApp extends StatelessWidget {
  const ApplianceRepairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appliance Repair',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: JobListScreen(api: ApiClient()),
    );
  }
}
