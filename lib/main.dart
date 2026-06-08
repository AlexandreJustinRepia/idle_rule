import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/custom_navbar.dart';
import 'components/custom_bottom_navbar.dart';
import 'components/stats_panel.dart';
import 'components/ghetto_environment.dart';
import 'game_state.dart';

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PlayerStats _stats = const PlayerStats();
  int _playerHealth = 30;
  double _playerStamina = const PlayerStats().maxStamina;
  double _playerHunger = const PlayerStats().maxHunger;

  void _gainStats({
    double strength = 0,
    double speed = 0,
    double endurance = 0,
  }) {
    setState(() {
      final previousMaxStamina = _stats.maxStamina;
      final previousMaxHunger = _stats.maxHunger;
      _stats = _stats.gain(
        strength: strength,
        speed: speed,
        endurance: endurance,
      );
      _playerHealth = _playerHealth.clamp(0, _stats.maxHealth).toInt();
      _playerStamina =
          (_playerStamina + (_stats.maxStamina - previousMaxStamina)).clamp(
            0,
            _stats.maxStamina,
          );
      _playerHunger = (_playerHunger + (_stats.maxHunger - previousMaxHunger))
          .clamp(0, _stats.maxHunger);
    });
  }

  void _takeDamage(int damage) {
    setState(() {
      _playerHealth = (_playerHealth - damage)
          .clamp(0, _stats.maxHealth)
          .toInt();
    });
  }

  void _recoverFromDefeat() {
    setState(() {
      _playerHealth = _stats.maxHealth;
      _playerStamina = _stats.maxStamina;
      _playerHunger = _stats.maxHunger;
    });
  }

  bool _spendStamina(double amount) {
    if (_playerStamina < amount) return false;

    setState(() {
      _playerStamina = (_playerStamina - amount).clamp(0, _stats.maxStamina);
    });
    return true;
  }

  void _recoverNeeds({double stamina = 0, double hunger = 0}) {
    setState(() {
      _playerStamina = (_playerStamina + stamina).clamp(0, _stats.maxStamina);
      _playerHunger = (_playerHunger + hunger).clamp(0, _stats.maxHunger);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomNavbar(),
      bottomNavigationBar: const CustomBottomNavbar(),
      body: Container(
        color: Colors.grey[900], // Darker background for game feel
        child: Column(
          children: [
            Expanded(
              child: GhettoEnvironment(
                stats: _stats,
                playerHealth: _playerHealth,
                playerMaxHealth: _stats.maxHealth,
                playerStamina: _playerStamina,
                playerMaxStamina: _stats.maxStamina,
                playerHunger: _playerHunger,
                playerMaxHunger: _stats.maxHunger,
                onStatsGained: _gainStats,
                onPlayerDamaged: _takeDamage,
                onPlayerDefeated: _recoverFromDefeat,
                onStaminaSpent: _spendStamina,
                onNeedsRecovered: _recoverNeeds,
              ),
            ),
            StatsPanel(stats: _stats),
          ],
        ),
      ),
    );
  }
}
