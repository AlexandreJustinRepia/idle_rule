import 'package:flutter/material.dart';

import '../../../controllers/game_controller.dart';
import 'ghetto_turf_map.dart';
import 'turf_map.dart';

class TurfScreen extends StatefulWidget {
  final GameController gameController;
  final TurfMapData? mapData;
  final String? characterName;
  final String? worldName;
  final String? locationStreetId;
  final List<String> residents;

  const TurfScreen({
    super.key,
    required this.gameController,
    this.mapData,
    this.characterName,
    this.worldName,
    this.locationStreetId,
    this.residents = const [],
  });

  @override
  State<TurfScreen> createState() => _TurfScreenState();
}

class _TurfScreenState extends State<TurfScreen> {
  late String _selectedTerritoryId;
  final Set<String> _conqueredTerritoryIds = {};

  TurfMapData get _mapData => widget.mapData ?? ghettoTurfMap;

  TurfTerritory get _selectedTerritory =>
      _mapData.territoryById(_selectedTerritoryId);

  @override
  void initState() {
    super.initState();
    _selectedTerritoryId = widget.locationStreetId ?? _mapData.spawnStreetId;
  }

  void _selectTerritory(TurfTerritory territory) {
    setState(() => _selectedTerritoryId = territory.id);
  }

  List<TurfTerritory> _childrenOf(String? parentId) {
    return _mapData.territories
        .where((territory) => territory.parentId == parentId)
        .toList();
  }

  void _conquerSelectedTerritory() {
    final territory = _selectedTerritory;
    if (territory.level != TurfMapLevel.street) return;
    if (_conqueredTerritoryIds.contains(territory.id)) return;

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

    setState(() => _conqueredTerritoryIds.add(territory.id));
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
    final isStreet = selected.level == TurfMapLevel.street;
    final isConquered = _conqueredTerritoryIds.contains(selected.id);
    final canAttack =
        isStreet &&
        !isConquered &&
        widget.gameController.hasGang &&
        widget.gameController.gangFormationSize > 0;

    return SafeArea(
      top: true,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TurfHeader(mapData: _mapData),
            const SizedBox(height: 10),
            _SpawnLine(
              characterName: widget.characterName,
              worldName: widget.worldName,
              locationStreet: _mapData.territoryById(
                widget.locationStreetId ?? _mapData.spawnStreetId,
              ),
              residents: widget.residents,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF101214),
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    for (final territory in _childrenOf(null))
                      _TurfTextNode(
                        territory: territory,
                        childrenOf: _childrenOf,
                        selectedTerritoryId: _selectedTerritoryId,
                        spawnStreetId: _mapData.spawnStreetId,
                        conqueredTerritoryIds: _conqueredTerritoryIds,
                        onSelected: _selectTerritory,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            _SelectedTurfBar(
              territory: selected,
              isConquered: isConquered,
              canAttack: canAttack,
              hasGang: widget.gameController.hasGang,
              hasFormation: widget.gameController.gangFormationSize > 0,
              onAttack: _conquerSelectedTerritory,
            ),
          ],
        ),
      ),
    );
  }
}

class _TurfHeader extends StatelessWidget {
  final TurfMapData mapData;

  const _TurfHeader({required this.mapData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mapData.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          mapData.subtitle,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
        ),
      ],
    );
  }
}

class _SpawnLine extends StatelessWidget {
  final String? characterName;
  final String? worldName;
  final TurfTerritory locationStreet;
  final List<String> residents;

  const _SpawnLine({
    required this.locationStreet,
    required this.residents,
    this.characterName,
    this.worldName,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF17191C),
        border: Border.all(
          color: const Color(0xFFFFD166).withValues(alpha: 0.45),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            const Icon(
              Icons.person_pin_circle,
              color: Color(0xFFFFD166),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${characterName ?? 'Character'} is in ${worldName ?? 'this world'} at ${locationStreet.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    residents.isEmpty
                        ? 'No other characters here yet.'
                        : 'Also here: ${residents.join(', ')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.52),
                      fontSize: 11,
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
}

class _TurfTextNode extends StatelessWidget {
  final TurfTerritory territory;
  final List<TurfTerritory> Function(String? parentId) childrenOf;
  final String selectedTerritoryId;
  final String spawnStreetId;
  final Set<String> conqueredTerritoryIds;
  final ValueChanged<TurfTerritory> onSelected;

  const _TurfTextNode({
    required this.territory,
    required this.childrenOf,
    required this.selectedTerritoryId,
    required this.spawnStreetId,
    required this.conqueredTerritoryIds,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final children = childrenOf(territory.id);
    final isStreet = territory.level == TurfMapLevel.street;
    final isSelected = territory.id == selectedTerritoryId;
    final isSpawn = territory.id == spawnStreetId;
    final isConquered = conqueredTerritoryIds.contains(territory.id);

    if (children.isEmpty) {
      return _TextTerritoryRow(
        territory: territory,
        isSelected: isSelected,
        isSpawn: isSpawn,
        isConquered: isConquered,
        onTap: () => onSelected(territory),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: territory.level.depth <= 1,
        tilePadding: EdgeInsets.only(
          left: 12 + territory.level.depth * 14,
          right: 10,
        ),
        childrenPadding: EdgeInsets.zero,
        iconColor: Colors.white70,
        collapsedIconColor: Colors.white38,
        title: _TextTerritoryTitle(
          territory: territory,
          isSelected: isSelected,
          isSpawn: isSpawn,
          isConquered: isConquered,
          onTap: () => onSelected(territory),
        ),
        subtitle: Text(
          '${children.length} ${_childLabel(isStreet, children.first.level)}',
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
        children: [
          for (final child in children)
            _TurfTextNode(
              territory: child,
              childrenOf: childrenOf,
              selectedTerritoryId: selectedTerritoryId,
              spawnStreetId: spawnStreetId,
              conqueredTerritoryIds: conqueredTerritoryIds,
              onSelected: onSelected,
            ),
        ],
      ),
    );
  }

  String _childLabel(bool isStreet, TurfMapLevel level) {
    final label = level.label.toLowerCase();
    return isStreet ? label : '${label}s';
  }
}

class _TextTerritoryRow extends StatelessWidget {
  final TurfTerritory territory;
  final bool isSelected;
  final bool isSpawn;
  final bool isConquered;
  final VoidCallback onTap;

  const _TextTerritoryRow({
    required this.territory,
    required this.isSelected,
    required this.isSpawn,
    required this.isConquered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16 + territory.level.depth * 14,
          right: 10,
          top: 6,
          bottom: 6,
        ),
        child: _TextTerritoryTitle(
          territory: territory,
          isSelected: isSelected,
          isSpawn: isSpawn,
          isConquered: isConquered,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _TextTerritoryTitle extends StatelessWidget {
  final TurfTerritory territory;
  final bool isSelected;
  final bool isSpawn;
  final bool isConquered;
  final VoidCallback onTap;

  const _TextTerritoryTitle({
    required this.territory,
    required this.isSelected,
    required this.isSpawn,
    required this.isConquered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = [
      if (isSpawn) 'SPAWN',
      if (isConquered) 'RULED',
      if (isSelected) 'SELECTED',
    ].join('  ');

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            _iconForLevel(territory.level),
            size: 15,
            color: isConquered
                ? const Color(0xFF2DDA77)
                : isSpawn
                ? const Color(0xFFFFD166)
                : Colors.white54,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${territory.level.label}: ${territory.label}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: territory.level == TurfMapLevel.street ? 13 : 14,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          if (status.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              status,
              style: TextStyle(
                color: isConquered
                    ? const Color(0xFF2DDA77)
                    : isSpawn
                    ? const Color(0xFFFFD166)
                    : Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconForLevel(TurfMapLevel level) {
    return switch (level) {
      TurfMapLevel.world => Icons.public,
      TurfMapLevel.country => Icons.flag,
      TurfMapLevel.region => Icons.map,
      TurfMapLevel.province => Icons.account_balance,
      TurfMapLevel.city => Icons.location_city,
      TurfMapLevel.town => Icons.home_work,
      TurfMapLevel.street => Icons.signpost,
    };
  }
}

class _SelectedTurfBar extends StatelessWidget {
  final TurfTerritory territory;
  final bool isConquered;
  final bool canAttack;
  final bool hasGang;
  final bool hasFormation;
  final VoidCallback onAttack;

  const _SelectedTurfBar({
    required this.territory,
    required this.isConquered,
    required this.canAttack,
    required this.hasGang,
    required this.hasFormation,
    required this.onAttack,
  });

  @override
  Widget build(BuildContext context) {
    final isStreet = territory.level == TurfMapLevel.street;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF101214),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${territory.level.label}: ${territory.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _subtitleText(isStreet),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (isStreet)
              ElevatedButton.icon(
                onPressed: canAttack ? onAttack : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isConquered
                      ? Colors.grey[700]
                      : const Color(0xFFE24B4A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(isConquered ? Icons.check : Icons.flag, size: 18),
                label: Text(
                  isConquered ? 'RULED' : _buttonText(),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _subtitleText(bool isStreet) {
    if (!isStreet) return 'Open this branch and select a street to rule.';
    if (isConquered) return 'This street is under your control.';
    return territory.description;
  }

  String _buttonText() {
    if (!hasGang) return 'NO GANG';
    if (!hasFormation) return 'NO CREW';
    return 'RULE';
  }
}
