import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wcgjdpxgajidhcqnaium.supabase.co',
    anonKey: 'sb_publishable_zQyMCUny3P2l39Iqvg5pjw_OePYBFqq',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Mind Track'),
        ),
      ),
    );
  }
}
