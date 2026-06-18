import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/navigation/custom_navbar.dart';
import 'components/navigation/custom_bottom_navbar.dart';
import 'components/ui/debug_stats_modal.dart';
import 'components/ui/stats_panel.dart';
import 'components/ui/gangs_view.dart';
import 'components/ui/shop_view.dart';
import 'components/environments/ghetto_environment.dart';
import 'components/environments/gym_environment.dart';
import 'components/environments/turf/turf_screen.dart';
import 'components/screens/loading_screen.dart';
import 'components/screens/character_creation_screen.dart';
import 'controllers/game_controller.dart';
import 'game_state.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  GoogleFonts.config.allowRuntimeFetching = false;
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
          seedColor: const Color(0xFFE24B4A),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.bebasNeueTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const AppFlow(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum AppFlowPhase { loading, creation, game }

class AppFlow extends StatefulWidget {
  const AppFlow({super.key});

  @override
  State<AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> {
  GameController? _gameController;
  AppFlowPhase _phase = AppFlowPhase.loading;
  int _currentTabIndex = 0;

  void _onLoadingComplete() {
    if (!mounted) return;
    setState(() => _phase = AppFlowPhase.creation);
  }

  void _onCharacterCreated({
    required String playerName,
    required CharacterClass characterClass,
    required double strength,
    required double speed,
    required double endurance,
    required double intelligence,
    required double potential,
    required double reputation,
  }) {
    if (!mounted) return;
    setState(() {
      _gameController = GameController(
        playerName: playerName,
        characterClass: characterClass,
        initialStats: PlayerStats(
          strength: strength,
          speed: speed,
          endurance: endurance,
          intelligence: intelligence,
          potential: potential,
          reputation: reputation,
        ),
      );
      _phase = AppFlowPhase.game;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case AppFlowPhase.loading:
        return LoadingScreen(onComplete: _onLoadingComplete);
      case AppFlowPhase.creation:
        return CharacterCreationScreen(onCharacterCreated: _onCharacterCreated);
      case AppFlowPhase.game:
        if (_gameController == null) {
          return const SizedBox.shrink();
        }
        return _GameScreen(
          gameController: _gameController!,
          currentTabIndex: _currentTabIndex,
          onTabChanged: (index) => setState(() => _currentTabIndex = index),
        );
    }
  }
}

class _GameScreen extends StatelessWidget {
  final GameController gameController;
  final int currentTabIndex;
  final Function(int) onTabChanged;

  const _GameScreen({
    required this.gameController,
    required this.currentTabIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameController,
      builder: (context, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: CustomNavbar(
            money: gameController.money,
            playerName: gameController.playerName,
            onMenuPressed: () => showDialog(
              context: context,
              builder: (context) =>
                  DebugStatsModal(gameController: gameController),
            ),
          ),
          bottomNavigationBar: CustomBottomNavbar(
            currentIndex: currentTabIndex,
            onTap: onTabChanged,
          ),
          body: Container(
            color: const Color(0xFF0A0A0A),
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: IndexedStack(
                    index: currentTabIndex,
                    children: [
                      GhettoEnvironment(
                        stats: gameController.stats,
                        playerHealth: gameController.playerHealth,
                        playerMaxHealth: gameController.stats.maxHealth,
                        playerStamina: gameController.playerStamina,
                        playerMaxStamina: gameController.stats.maxStamina,
                        playerHunger: gameController.playerHunger,
                        playerMaxHunger: gameController.stats.maxHunger,
                        onStatsGained: gameController.gainStats,
                        onPlayerDamaged: gameController.takeDamage,
                        onPlayerDefeated: gameController.recoverFromDefeat,
                        onNewEnemyApproached:
                            gameController.recoverHealthForNewEnemy,
                        onStaminaSpent: gameController.spendStamina,
                        onNeedsRecovered: gameController.recoverNeeds,
                        activeBoss: gameController.activeBoss,
                        onBossDefeated: gameController.onBossDefeated,
                        onStartBossFight: gameController.startBossFight,
                        bossIndex: gameController.bossIndex,
                        onMoneyGained: gameController.gainMoney,
                        hasGang: gameController.hasGang,
                        gangMembers: gameController.gangMembers,
                        onGangMemberRecruited: gameController.recruitGangMember,
                        onGangMemberDismissed: gameController.dismissGangMember,
                      ),
                      GymEnvironment(
                        stats: gameController.stats,
                        playerStamina: gameController.playerStamina,
                        playerHunger: gameController.playerHunger,
                        onStatsGained: gameController.gainStats,
                        onStaminaSpent: gameController.spendStamina,
                        onNeedsRecovered: gameController.recoverNeeds,
                      ),
                      ShopView(gameController: gameController),
                      TurfScreen(gameController: gameController),
                      GangsView(gameController: gameController),
                    ],
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: StatsPanel(stats: gameController.stats),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
