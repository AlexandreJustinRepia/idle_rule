import 'package:flutter/material.dart';
import '../../../controllers/game_controller.dart';
import 'ghetto_turf_map.dart';
import 'turf_map.dart';

class TurfScreen extends StatefulWidget {
  final GameController gameController;
  final TurfMapData mapData;

  const TurfScreen({
    super.key,
    required this.gameController,
    this.mapData = ghettoTurfMap,
  });

  @override
  State<TurfScreen> createState() => _TurfScreenState();
}

class _TurfScreenState extends State<TurfScreen> {
  late String _selectedTerritoryId;
  final Set<String> _conqueredTerritoryIds = {};

  TurfTerritory get _selectedTerritory => widget.mapData.territories.firstWhere(
    (territory) => territory.id == _selectedTerritoryId,
  );

  @override
  void initState() {
    super.initState();
    _selectedTerritoryId = widget.mapData.territories.first.id;
  }

  void _selectTerritory(TurfTerritory territory) {
    setState(() {
      _selectedTerritoryId = territory.id;
    });
  }

  void _conquerSelectedTerritory() {
    if (_conqueredTerritoryIds.contains(_selectedTerritoryId)) return;
    final territory = _selectedTerritory;
    final succeeded = widget.gameController.attemptTurfTakeover(
      territory.defense,
    );
    if (!mounted) return;
    if (!succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${territory.label.toUpperCase()} TAKEOVER FAILED'),
          duration: const Duration(milliseconds: 1100),
        ),
      );
      return;
    }
    setState(() {
      _conqueredTerritoryIds.add(_selectedTerritoryId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${territory.label.toUpperCase()} SECURED'),
        duration: const Duration(milliseconds: 1100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedTerritory;
    final bool isConquered = _conqueredTerritoryIds.contains(selected.id);
    final chance = widget.gameController.turfTakeoverChance(selected.defense);
    final canAttack =
        !isConquered &&
        widget.gameController.hasGang &&
        widget.gameController.gangFormationSize > 0;

    return SafeArea(
      top: true,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.mapData.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.mapData.subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            Flexible(
              fit: FlexFit.loose,
              child: TurfMapView(
                mapData: widget.mapData,
                selectedTerritoryId: _selectedTerritoryId,
                conqueredTerritoryIds: _conqueredTerritoryIds,
                onTerritoryTap: _selectTerritory,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selected.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isConquered ? 'CONQUERED' : 'AVAILABLE',
                        style: TextStyle(
                          color: isConquered
                              ? const Color(0xFF34C759)
                              : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selected.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTurfMetric(
                          'GANG POWER',
                          widget.gameController.gangAttackPower.toString(),
                          Icons.groups,
                          const Color(0xFFE24B4A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTurfMetric(
                          'DEFENSE',
                          selected.defense.toString(),
                          Icons.shield,
                          Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTurfMetric(
                          'CHANCE',
                          '${(chance * 100).round()}%',
                          Icons.casino,
                          const Color(0xFF34C759),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isConquered
                            ? Colors.grey[700]
                            : const Color(0xFFE24B4A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: canAttack ? _conquerSelectedTerritory : null,
                      child: Text(
                        isConquered
                            ? 'TERRITORY SECURED'
                            : widget.gameController.hasGang
                            ? widget.gameController.gangFormationSize > 0
                                  ? 'SEND FORMATION'
                                  : 'ASSEMBLE FORMATION'
                            : 'CREATE A GANG FIRST',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurfMetric(
    String label,
    String value,
    IconData icon,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 16),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
