import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/navigation/custom_navbar.dart';
import 'components/navigation/custom_bottom_navbar.dart';
import 'components/ui/stats_panel.dart';
import 'components/ui/placeholder_view.dart';
import 'components/environments/ghetto_environment.dart';
import 'components/environments/gym_environment.dart';
import 'controllers/game_controller.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
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
  final GameController _gameController = GameController();
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _gameController,
      builder: (context, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: CustomNavbar(money: _gameController.money),
          bottomNavigationBar: CustomBottomNavbar(
            currentIndex: _currentTabIndex,
            onTap: (index) => setState(() => _currentTabIndex = index),
          ),
          body: Container(
            color: Colors.black,
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: IndexedStack(
                    index: _currentTabIndex,
                    children: [
                      GhettoEnvironment(
                        stats: _gameController.stats,
                        playerHealth: _gameController.playerHealth,
                        playerMaxHealth: _gameController.stats.maxHealth,
                        playerStamina: _gameController.playerStamina,
                        playerMaxStamina: _gameController.stats.maxStamina,
                        playerHunger: _gameController.playerHunger,
                        playerMaxHunger: _gameController.stats.maxHunger,
                        onStatsGained: _gameController.gainStats,
                        onPlayerDamaged: _gameController.takeDamage,
                        onPlayerDefeated: _gameController.recoverFromDefeat,
                        onNewEnemyApproached: _gameController.recoverHealthForNewEnemy,
                        onStaminaSpent: _gameController.spendStamina,
                        onNeedsRecovered: _gameController.recoverNeeds,
                        activeBoss: _gameController.activeBoss,
                        onBossDefeated: _gameController.onBossDefeated,
                        onStartBossFight: _gameController.startBossFight,
                        bossIndex: _gameController.bossIndex,
                        onMoneyGained: _gameController.gainMoney,
                      ),
                      GymEnvironment(
                        stats: _gameController.stats,
                        playerStamina: _gameController.playerStamina,
                        playerHunger: _gameController.playerHunger,
                        onStatsGained: _gameController.gainStats,
                        onStaminaSpent: _gameController.spendStamina,
                        onNeedsRecovered: _gameController.recoverNeeds,
                      ),
                      const PlaceholderView(title: 'SHOP'),
                      const PlaceholderView(title: 'TURFS'),
                      const PlaceholderView(title: 'GANGS'),
                    ],
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: StatsPanel(stats: _gameController.stats),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
