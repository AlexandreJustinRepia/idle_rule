import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/custom_navbar.dart';
import 'components/custom_bottom_navbar.dart';
import 'components/stats_panel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Idle Rule',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomNavbar(),
      bottomNavigationBar: const CustomBottomNavbar(),
      body: Container(
        color: Colors.grey[900], // Darker background for game feel
        child: const Column(
          children: [
            SizedBox(height: 100), // Space for top navbar
            Expanded(
              child: Center(
                child: Text('Game Content Goes Here', style: TextStyle(fontSize: 24, color: Colors.grey)),
              ),
            ),
            StatsPanel(),
          ],
        ),
      ),
    );
  }
}
