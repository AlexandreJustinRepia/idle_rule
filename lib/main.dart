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
import 'components/screens/world_loading_screen.dart';
import 'components/screens/character_creation_screen.dart';
import 'components/ui/character_customize_screen.dart';
import 'components/shared/character_placeholders.dart';
import 'controllers/game_controller.dart';
import 'game_state.dart';
import 'models/world_session.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/environments/turf/turf_map.dart';
import 'logic/world_generator.dart';

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

enum AppFlowPhase { loading, creation, worldSelection, worldLoading, game }

class AppFlow extends StatefulWidget {
  const AppFlow({super.key});

  @override
  State<AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> {
  AppFlowPhase _phase = AppFlowPhase.loading;
  final List<GameCharacterSession> _characters = [];
  final List<GameWorld> _worlds = [];
  GameCharacterSession? _activeCharacter;
  GameCharacterSession? _selectedCharacter;
  GameCharacterSession? _pendingWorldCharacter;
  GameWorld? _pendingWorld;
  bool _pendingWorldNeedsGeneration = false;
  int _currentTabIndex = 0;
  int _nextCharacterId = 1;
  int _nextWorldId = 1;
  String? _previousLocationStreetId;

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
    required CharacterCustomization customization,
  }) {
    if (!mounted) return;
    setState(() {
      final controller = GameController(
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
      controller.updateCustomization(customization);
      final character = GameCharacterSession(
        id: 'character_${_nextCharacterId++}',
        controller: controller,
      );
      _characters.add(character);
      _activeCharacter = character;
      _selectedCharacter = character;
      _phase = AppFlowPhase.worldSelection;
    });
  }

  GameWorld _createWorld(String name) {
    final worldNumber = _nextWorldId++;
    final world = GameWorld(
      id: 'world_$worldNumber',
      name: name.trim().isEmpty ? 'New World $worldNumber' : name.trim(),
      seed: DateTime.now().microsecondsSinceEpoch,
    );
    _worlds.add(world);
    return world;
  }

  void _startNewCharacter() {
    setState(() => _phase = AppFlowPhase.creation);
  }

  void _addWorld(String name) {
    setState(() {
      _createWorld(name);
    });
  }

  void _deleteWorld(GameWorld world) {
    setState(() {
      _worlds.removeWhere((candidate) => candidate.id == world.id);
      for (final character in _characters) {
        if (character.worldId == world.id) {
          character.worldId = null;
          character.locationStreetId = null;
        }
      }
      if (_activeCharacter?.worldId == world.id) {
        _activeCharacter = null;
      }
    });
  }

  void _deleteCharacter(GameCharacterSession character) {
    setState(() {
      _characters.removeWhere((candidate) => candidate.id == character.id);
      if (_selectedCharacter?.id == character.id) {
        _selectedCharacter = _characters.isEmpty ? null : _characters.first;
      }
      if (_activeCharacter?.id == character.id) {
        _activeCharacter = null;
      }
    });
  }

  void _enterWorld(GameCharacterSession character, GameWorld world) {
    setState(() {
      _pendingWorldCharacter = character;
      _pendingWorld = world;
      _pendingWorldNeedsGeneration = world.mapData == null;
      _phase = AppFlowPhase.worldLoading;
    });
  }

  void _finishEnterWorld() {
    final character = _pendingWorldCharacter;
    final world = _pendingWorld;
    if (character == null || world == null) {
      setState(() => _phase = AppFlowPhase.worldSelection);
      return;
    }

    setState(() {
      if (world.mapData == null) {
        final result = WorldGenerator.generateWorld(world.seed);
        world.mapData = result.mapData;
        world.rivalGangs = result.rivalGangs;
        world.interactableNpcs = result.interactableNpcs;
      }

      final changedWorld = character.worldId != world.id;
      character.worldId = world.id;
      if (changedWorld || character.locationStreetId == null) {
        character.locationStreetId = world.mapData!.spawnStreetId;
      }
      _previousLocationStreetId = character.locationStreetId;
      _activeCharacter = character;
      _pendingWorldCharacter = null;
      _pendingWorld = null;
      _pendingWorldNeedsGeneration = false;
      _currentTabIndex = 0;
      _phase = AppFlowPhase.game;
    });
  }

  void _quitToWorlds() {
    setState(() {
      _selectedCharacter = _activeCharacter;
      _activeCharacter = null;
      _phase = AppFlowPhase.worldSelection;
    });
  }

  void _selectCharacter(GameCharacterSession character) {
    setState(() => _selectedCharacter = character);
  }

  GameWorld? _worldById(String? id) {
    if (id == null) return null;
    for (final world in _worlds) {
      if (world.id == id) return world;
    }
    return null;
  }

  List<GameCharacterSession> _charactersInWorld(GameWorld world) {
    return _characters
        .where((character) => character.worldId == world.id)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case AppFlowPhase.loading:
        return LoadingScreen(onComplete: _onLoadingComplete);
      case AppFlowPhase.creation:
        return CharacterCreationScreen(onCharacterCreated: _onCharacterCreated);
      case AppFlowPhase.worldSelection:
        return _WorldSelectionScreen(
          characters: _characters,
          worlds: _worlds,
          selectedCharacter: _selectedCharacter,
          worldById: _worldById,
          charactersInWorld: _charactersInWorld,
          onCreateCharacter: _startNewCharacter,
          onCreateWorld: _addWorld,
          onDeleteWorld: _deleteWorld,
          onDeleteCharacter: _deleteCharacter,
          onSelectCharacter: _selectCharacter,
          onEnterWorld: _enterWorld,
        );
      case AppFlowPhase.worldLoading:
        final world = _pendingWorld;
        if (world == null) {
          return const SizedBox.shrink();
        }
        return WorldLoadingScreen(
          worldName: world.name,
          isGenerating: _pendingWorldNeedsGeneration,
          onComplete: _finishEnterWorld,
        );
      case AppFlowPhase.game:
        final activeCharacter = _activeCharacter;
        final activeWorld = _worldById(activeCharacter?.worldId);
        if (activeCharacter == null || activeWorld == null) {
          return const SizedBox.shrink();
        }
        return _GameScreen(
          character: activeCharacter,
          world: activeWorld,
          worldResidents: _charactersInWorld(activeWorld),
          currentTabIndex: _currentTabIndex,
          onTabChanged: (index) => setState(() => _currentTabIndex = index),
          onQuit: _quitToWorlds,
          onLocationChanged: (newStreetId) {
            setState(() {
              activeCharacter.locationStreetId = newStreetId;
            });
          },
          onTurfConquestStarted: (request) {
            setState(() {
              _previousLocationStreetId = activeCharacter.locationStreetId;
              _currentTabIndex = 0;
            });
          },
          onSoloTurfConquestFailed: (territoryId) {
            final result = activeCharacter.controller.failSoloTurfConquest(
              territoryId,
            );
            if (_previousLocationStreetId != null) {
              activeCharacter.locationStreetId = _previousLocationStreetId!;
              _previousLocationStreetId = null;
            }
            return result;
          },
          onPlayerDefeated: () {
            final spawnStreetId = activeWorld.mapData!.spawnStreetId;
            final defeatedStreetId =
                activeCharacter.locationStreetId ?? spawnStreetId;
            final recoveryStreetId =
                activeCharacter.controller.hasSafeHouseAt(defeatedStreetId)
                ? defeatedStreetId
                : spawnStreetId;
            setState(() {
              activeCharacter.locationStreetId = recoveryStreetId;
            });
            activeCharacter.controller.recoverFromDefeat();
          },
        );
    }
  }
}

class _GameScreen extends StatelessWidget {
  final GameCharacterSession character;
  final GameWorld world;
  final List<GameCharacterSession> worldResidents;
  final int currentTabIndex;
  final Function(int) onTabChanged;
  final VoidCallback onQuit;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<PendingTurfConquest> onTurfConquestStarted;
  final TurfAttackResult Function(String territoryId)? onSoloTurfConquestFailed;
  final VoidCallback onPlayerDefeated;

  const _GameScreen({
    required this.character,
    required this.world,
    required this.worldResidents,
    required this.currentTabIndex,
    required this.onTabChanged,
    required this.onQuit,
    required this.onLocationChanged,
    required this.onTurfConquestStarted,
    required this.onPlayerDefeated,
    this.onSoloTurfConquestFailed,
  });

  @override
  Widget build(BuildContext context) {
    final gameController = character.controller;
    final location = world.mapData!.territoryById(
      character.locationStreetId ?? world.mapData!.spawnStreetId,
    );
    return ListenableBuilder(
      listenable: gameController,
      builder: (context, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: CustomNavbar(
            money: gameController.money,
            playerName: gameController.playerName,
            locationLabel: '${world.name} / ${location.label}',
            onMenuPressed: () => showModalBottomSheet(
              context: context,
              backgroundColor: const Color(0xFF111111),
              builder: (context) => _GameMenuSheet(
                gameController: gameController,
                world: world,
                location: location,
                onQuit: onQuit,
              ),
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
                        backgroundAsset:
                            location.backgroundAsset ??
                            'assets/background/ghetto.png',
                        onStatsGained: gameController.gainStats,
                        onPlayerDamaged: gameController.takeDamage,
                        onPlayerDefeated: onPlayerDefeated,
                        onNewEnemyApproached:
                            gameController.recoverHealthForNewEnemy,
                        onStaminaSpent: gameController.spendStamina,
                        onNeedsRecovered: gameController.recoverNeeds,
                        activeBoss: gameController.activeBoss,
                        onBossDefeated: gameController.onBossDefeated,
                        onStartBossFight: gameController.startBossFight,
                        bossIndex: gameController.bossIndex,
                        activePlayerChallenge: gameController.activePlayerChallenge,
                        onPlayerChallengeDefeated: gameController.onPlayerChallengeDefeated,
                        onMoneyGained: gameController.gainMoney,
                        hasGang: gameController.hasGang,
                        gangMembers: gameController.formationMembers,
                        isPlayerInFormation: gameController.isPlayerInFormation,
                        onGangMemberRecruited: gameController.recruitGangMember,
                        onGangMemberDismissed: gameController.dismissGangMember,
                        pendingTurfConquest: gameController.pendingTurfConquest,
                        onSoloTurfConquestCleared:
                            gameController.completeSoloTurfConquest,
                        onSoloTurfConquestFailed: onSoloTurfConquestFailed,
                        hasSafeHouse:
                            character.locationStreetId ==
                                world.mapData!.spawnStreetId ||
                            gameController.hasSafeHouseAt(
                              character.locationStreetId ??
                                  world.mapData!.spawnStreetId,
                            ),
                        isHostileStreet: gameController
                            .isSoloRaidFailedTerritory(
                              character.locationStreetId ??
                                  world.mapData!.spawnStreetId,
                            ),
                        rivalGangs: world.rivalGangs,
                        customization: gameController.customization,
                        streetControllingGangName: gameController.isTerritoryConquered(
                                  character.locationStreetId ??
                                      world.mapData!.spawnStreetId,
                                )
                            ? null
                            : location.occupyingGangId,
                        isActive: currentTabIndex == 0,
                      ),
                      GymEnvironment(
                        stats: gameController.stats,
                        playerHealth: gameController.playerHealth,
                        playerStamina: gameController.playerStamina,
                        playerHunger: gameController.playerHunger,
                        hasGang: gameController.hasGang,
                        isActive: currentTabIndex == 1,
                        onStatsGained: gameController.gainStats,
                        onStaminaSpent: gameController.spendStamina,
                        onNeedsRecovered: gameController.recoverNeeds,
                      ),
                      ShopView(
                        gameController: gameController,
                        currentStreet: location,
                        spawnStreetId: world.mapData!.spawnStreetId,
                      ),
                      TurfScreen(
                        gameController: gameController,
                        mapData: world.mapData!,
                        characterName: gameController.playerName,
                        worldName: world.name,
                        locationStreetId: character.locationStreetId,
                        worldResidents: worldResidents,
                        onLocationChanged: onLocationChanged,
                        onSoloTurfConquestStarted: onTurfConquestStarted,
                        rivalGangs: world.rivalGangs,
                        interactableNpcs: world.interactableNpcs,
                        onFightStarted: () => onTabChanged(0),
                      ),
                      GangsView(gameController: gameController),
                    ],
                  ),
                ),
                if (currentTabIndex != 3 && currentTabIndex != 4)
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

enum _LobbyPage { characters, worlds }

class _WorldSelectionScreen extends StatefulWidget {
  final List<GameCharacterSession> characters;
  final List<GameWorld> worlds;
  final GameCharacterSession? selectedCharacter;
  final GameWorld? Function(String? id) worldById;
  final List<GameCharacterSession> Function(GameWorld world) charactersInWorld;
  final VoidCallback onCreateCharacter;
  final ValueChanged<String> onCreateWorld;
  final ValueChanged<GameWorld> onDeleteWorld;
  final ValueChanged<GameCharacterSession> onDeleteCharacter;
  final ValueChanged<GameCharacterSession> onSelectCharacter;
  final void Function(GameCharacterSession character, GameWorld world)
  onEnterWorld;

  const _WorldSelectionScreen({
    required this.characters,
    required this.worlds,
    required this.selectedCharacter,
    required this.worldById,
    required this.charactersInWorld,
    required this.onCreateCharacter,
    required this.onCreateWorld,
    required this.onDeleteWorld,
    required this.onDeleteCharacter,
    required this.onSelectCharacter,
    required this.onEnterWorld,
  });

  @override
  State<_WorldSelectionScreen> createState() => _WorldSelectionScreenState();
}

class _WorldSelectionScreenState extends State<_WorldSelectionScreen> {
  _LobbyPage _page = _LobbyPage.characters;

  void _promptForWorldName(BuildContext context) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF121212),
          title: const Text('Create World'),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'Enter a world name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                Navigator.of(context).pop();
                widget.onCreateWorld(name);
              },
              child: const Text('CREATE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCharactersPage = _page == _LobbyPage.characters;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isCharactersPage ? 'CHARACTERS' : 'WORLDS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isCharactersPage
                    ? 'Choose who you want to play, or create another fighter.'
                    : 'Choose a world, then pick which character enters it. Deleting a world only removes the world.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _LobbyTabButton(
                      icon: Icons.person,
                      label: 'CHARACTERS',
                      isSelected: isCharactersPage,
                      onTap: () => setState(() => _page = _LobbyPage.characters),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LobbyTabButton(
                      icon: Icons.public,
                      label: 'WORLDS',
                      isSelected: !isCharactersPage,
                      onTap: () => setState(() => _page = _LobbyPage.worlds),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (isCharactersPage)
                _LobbyButton(
                  icon: Icons.person_add,
                  label: 'NEW CHARACTER',
                  onTap: widget.onCreateCharacter,
                )
              else
                _LobbyButton(
                  icon: Icons.add_location_alt,
                  label: 'CREATE WORLD',
                  onTap: () => _promptForWorldName(context),
                ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  children: isCharactersPage
                      ? [
                          const _LobbySectionTitle('CHARACTERS'),
                          if (widget.characters.isEmpty)
                            const _EmptyLobbyText(
                              'Create a character to begin.',
                            ),
                          for (final character in widget.characters)
                            _CharacterLobbyCard(
                              character: character,
                              currentWorld: widget.worldById(character.worldId),
                              isSelected:
                                  character.id == widget.selectedCharacter?.id,
                              onSelected: () {
                                widget.onSelectCharacter(character);
                                setState(() => _page = _LobbyPage.worlds);
                              },
                              onDelete: () => widget.onDeleteCharacter(character),
                            ),
                        ]
                      : [
                          const _LobbySectionTitle('WORLDS'),
                          if (widget.characters.isEmpty)
                            const _EmptyLobbyText(
                              'Create a character before entering a world.',
                            ),
                          if (widget.worlds.isEmpty)
                            const _EmptyLobbyText('Create a world to enter.'),
                          for (final world in widget.worlds)
                            _WorldLobbyCard(
                              world: world,
                              characters: widget.characters,
                              selectedCharacter: widget.selectedCharacter,
                              residents: widget.charactersInWorld(world),
                              onEnter: (character) {
                                widget.onSelectCharacter(character);
                                widget.onEnterWorld(character, world);
                              },
                              onDelete: () => widget.onDeleteWorld(world),
                            ),
                        ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterLobbyCard extends StatelessWidget {
  final GameCharacterSession character;
  final GameWorld? currentWorld;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback onDelete;

  const _CharacterLobbyCard({
    required this.character,
    required this.currentWorld,
    required this.isSelected,
    required this.onSelected,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final controller = character.controller;
    final location = currentWorld == null || character.locationStreetId == null
        ? null
        : currentWorld!.mapData?.territoryById(character.locationStreetId!);

    return _LobbyCard(
      isSelected: isSelected,
      child: InkWell(
        onTap: onSelected,
        child: Row(
          children: [
            _CharacterAvatarPreview(
              customization: controller.customization,
              isSelected: isSelected,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.playerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentWorld == null
                        ? 'No world selected'
                        : '${currentWorld!.name} / ${location?.label ?? 'No street'}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Text(
                'SELECTED',
                style: TextStyle(
                  color: Color(0xFFE24B4A),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            IconButton(
              tooltip: 'Delete character',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterAvatarPreview extends StatelessWidget {
  final CharacterCustomization customization;
  final bool isSelected;

  const _CharacterAvatarPreview({
    required this.customization,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(
          color: isSelected ? const Color(0xFFE24B4A) : Colors.white12,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 52,
          height: 112,
          child: HeroCharacterPlaceholder(customization: customization),
        ),
      ),
    );
  }
}

class _WorldLobbyCard extends StatelessWidget {
  final GameWorld world;
  final List<GameCharacterSession> characters;
  final GameCharacterSession? selectedCharacter;
  final List<GameCharacterSession> residents;
  final ValueChanged<GameCharacterSession> onEnter;
  final VoidCallback onDelete;

  const _WorldLobbyCard({
    required this.world,
    required this.characters,
    required this.selectedCharacter,
    required this.residents,
    required this.onEnter,
    required this.onDelete,
  });

  String _locationLabelFor(GameCharacterSession character) {
    final mapData = world.mapData;
    if (mapData == null) return 'Generating on first entry';

    final streetId = character.locationStreetId ?? mapData.spawnStreetId;
    try {
      final location = mapData.territoryById(streetId);
      final streetType = location.streetType?.label;
      return streetType == null ? location.label : '${location.label} / $streetType';
    } catch (_) {
      return 'Unknown street';
    }
  }
  void _showCharacterPicker(BuildContext context) {
    if (characters.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111111),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ENTER ${world.name.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a character for this world.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                       for (final character in characters)
                         _WorldCharacterChoice(
                           character: character,
                           isSelected: character.id == selectedCharacter?.id,
                           isResident: character.worldId == world.id,
                           onTap: () {
                             Navigator.of(context).pop();
                             onEnter(character);
                           },
                         ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentWorld = residents.any(
      (resident) => resident.id == selectedCharacter?.id,
    );

    return _LobbyCard(
      isSelected: isCurrentWorld,
      child: Row(
        children: [
          const Icon(Icons.public, color: Color(0xFFE24B4A)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  world.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                if (residents.isEmpty)
                  Text(
                    'No characters inside',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (final resident in residents)
                        _WorldResidentRow(
                          character: resident,
                          locationLabel: _locationLabelFor(resident),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: characters.isEmpty
                ? null
                : () => _showCharacterPicker(context),
            icon: const Icon(Icons.login, size: 16),
            label: const Text('ENTER'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE24B4A),
              disabledBackgroundColor: const Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Delete world',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _WorldCharacterChoice extends StatelessWidget {
  final GameCharacterSession character;
  final bool isSelected;
  final bool isResident;
  final VoidCallback onTap;

  const _WorldCharacterChoice({
    required this.character,
    required this.isSelected,
    required this.isResident,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = character.controller;

    return _LobbyCard(
      isSelected: isSelected,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            _CharacterAvatarPreview(
              customization: controller.customization,
              isSelected: isSelected,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.playerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isResident
                        ? 'Already in this world'
                        : 'Enter this world',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isResident ? Icons.home_work_rounded : Icons.login,
              color: isResident ? const Color(0xFFE24B4A) : Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorldResidentRow extends StatelessWidget {
  final GameCharacterSession character;
  final String locationLabel;

  const _WorldResidentRow({
    required this.character,
    required this.locationLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.person, size: 12, color: Colors.white54),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              character.controller.playerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            locationLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameMenuSheet extends StatelessWidget {
  final GameController gameController;
  final GameWorld world;
  final TurfTerritory location;
  final VoidCallback onQuit;

  const _GameMenuSheet({
    required this.gameController,
    required this.world,
    required this.location,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${world.name} / ${location.label}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CharacterCustomizeScreen(
                      gameController: gameController,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.face),
              label: const Text('CUSTOMIZE CHARACTER'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) =>
                      DebugStatsModal(gameController: gameController),
                );
              },
              icon: const Icon(Icons.tune),
              label: const Text('DEBUG STATS'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onQuit();
              },
              icon: const Icon(Icons.logout),
              label: const Text('QUIT TO CHARACTERS'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LobbyTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LobbyTabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.white60,
        backgroundColor: isSelected
            ? const Color(0xFFE24B4A)
            : const Color(0xFF111111),
        side: BorderSide(
          color: isSelected ? const Color(0xFFE24B4A) : Colors.white12,
        ),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
class _LobbyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LobbyButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE24B4A),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _LobbyCard extends StatelessWidget {
  final Widget child;
  final bool isSelected;

  const _LobbyCard({required this.child, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border.all(
          color: isSelected ? const Color(0xFFE24B4A) : Colors.white12,
          width: isSelected ? 1.4 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _LobbySectionTitle extends StatelessWidget {
  final String label;

  const _LobbySectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyLobbyText extends StatelessWidget {
  final String text;

  const _EmptyLobbyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: const TextStyle(color: Colors.white38)),
    );
  }
}




