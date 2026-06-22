import '../components/environments/turf/turf_map.dart';
import '../controllers/game_controller.dart';

class GameWorld {
  final String id;
  final String name;
  final TurfMapData mapData;

  const GameWorld({
    required this.id,
    required this.name,
    required this.mapData,
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
