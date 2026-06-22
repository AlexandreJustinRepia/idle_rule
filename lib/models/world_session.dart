import '../components/environments/turf/turf_map.dart';
import '../controllers/game_controller.dart';
import 'gang.dart';
import 'interactable_npc.dart';

class GameWorld {
  final String id;
  final String name;
  final int seed;
  TurfMapData? mapData;
  List<Gang> rivalGangs;
  List<InteractableNpc> interactableNpcs;

  GameWorld({
    required this.id,
    required this.name,
    required this.seed,
    this.mapData,
    this.rivalGangs = const [],
    this.interactableNpcs = const [],
  });
}

class GameCharacterSession {
  final String id;
  final GameController controller;
  String? worldId;
  String? locationStreetId;

  GameCharacterSession({
    required this.id,
    required this.controller,
    this.worldId,
    this.locationStreetId,
  });
}
