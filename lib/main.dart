import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/navigation/custom_navbar.dart';
import 'components/navigation/custom_bottom_navbar.dart';
import 'components/ui/stats_panel.dart';
import 'components/environments/ghetto_environment.dart';
import 'components/environments/gym_environment.dart';
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
        useMaterial3: true,
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
  Boss? _activeBoss;
  int _bossIndex = 0;
  int _currentTabIndex = 0;

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
      _playerHealth = (_playerHealth - damage).clamp(0, _stats.maxHealth).toInt();
    });
  }

  void _recoverFromDefeat() {
    setState(() {
      _playerHealth = _stats.maxHealth;
      _playerStamina = _stats.maxStamina;
      _playerHunger = _stats.maxHunger;
      _activeBoss = null; 
      _currentTabIndex = 0; 
    });
  }

  void _recoverHealthForNewEnemy() {
    setState(() {
      _playerHealth = _stats.maxHealth;
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

  void _startBossFight() {
    if (_activeBoss != null) return;
    setState(() {
      _activeBoss = gameBosses[_bossIndex % gameBosses.length];
      _playerHealth = _stats.maxHealth; 
    });
  }

  void _onBossDefeated() {
    setState(() {
      _activeBoss = null;
      _bossIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomNavbar(),
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
      ),
      body: Container(
        color: Colors.grey[900],
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  Stack(
                    children: [
                      GhettoEnvironment(
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
                        onNewEnemyApproached: _recoverHealthForNewEnemy,
                        onStaminaSpent: _spendStamina,
                        onNeedsRecovered: _recoverNeeds,
                        activeBoss: _activeBoss,
                        onBossDefeated: _onBossDefeated,
                      ),
                      if (_activeBoss == null)
                        Positioned(
                          bottom: 16,
                          right: 20,
                          child: _FightBossButton(
                            onPressed: _startBossFight,
                            nextBossName: gameBosses[_bossIndex % gameBosses.length].name,
                          ),
                        ),
                    ],
                  ),
                  GymEnvironment(
                    stats: _stats,
                    playerStamina: _playerStamina,
                    playerHunger: _playerHunger,
                    onStatsGained: _gainStats,
                    onStaminaSpent: _spendStamina,
                    onNeedsRecovered: _recoverNeeds,
                  ),
                  const Center(
                    child: Text(
                      'TURFS COMING SOON',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'GANGS COMING SOON',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 4,
              child: StatsPanel(stats: _stats),
            ),
          ],
        ),
      ),
    );
  }
}

class _FightBossButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String nextBossName;

  const _FightBossButton({required this.onPressed, required this.nextBossName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withValues(alpha: 0.6),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'FIGHT BOSS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            Text(
              nextBossName,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
