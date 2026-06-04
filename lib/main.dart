import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/custom_navbar.dart';
import 'components/custom_bottom_navbar.dart';

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
        color: Colors.grey[200],
        child: const Center(
          child: Text('Game Content Goes Here', style: TextStyle(fontSize: 24, color: Colors.grey)),
        ),
      ),
    );
  }
}
