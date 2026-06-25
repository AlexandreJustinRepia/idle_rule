import 'package:flutter/material.dart';
import '../../controllers/game_controller.dart';
import '../environments/turf/turf_map.dart';

class ShopItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color accentColor;
  final int cost;
  final double staminaRestore;
  final double hungerRestore;
  final int healthRestore;
  final bool isFood;
  final bool isSafeHouse;
  final bool isWeapon;
  final List<StreetType> streetTypes;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.cost,
    this.staminaRestore = 0,
    this.hungerRestore = 0,
    this.healthRestore = 0,
    this.isFood = false,
    this.isSafeHouse = false,
    this.isWeapon = false,
    this.streetTypes = const [],
  });
}

class ShopView extends StatelessWidget {
  final GameController gameController;
  final TurfTerritory currentStreet;
  final String spawnStreetId;

  const ShopView({
    super.key,
    required this.gameController,
    required this.currentStreet,
    required this.spawnStreetId,
  });

  static const List<ShopItem> _items = [
    ShopItem(
      id: 'energy_soda',
      name: 'Energy Soda',
      description: 'Quick carbonated pick-me-up. Restores stamina.',
      icon: Icons.local_drink,
      accentColor: Colors.cyanAccent,
      cost: 15,
      staminaRestore: 30,
      isFood: true,
    ),
    ShopItem(
      id: 'double_burger',
      name: 'Double Burger',
      description: 'Greasy double cheeseburger. Highly filling.',
      icon: Icons.fastfood,
      accentColor: Colors.orangeAccent,
      cost: 25,
      hungerRestore: 50,
      isFood: true,
    ),
    ShopItem(
      id: 'first_aid_kit',
      name: 'First Aid Kit',
      description: 'Sterile bandages and gauze to treat street wounds.',
      icon: Icons.healing,
      accentColor: Colors.redAccent,
      cost: 40,
      healthRestore: 40,
    ),
    ShopItem(
      id: 'vip_power_drink',
      name: 'VIP Power Drink',
      description: 'Premium formulation restoring all vital signs.',
      icon: Icons.bolt,
      accentColor: Colors.purpleAccent,
      cost: 100,
      staminaRestore: 50,
      hungerRestore: 50,
      healthRestore: 50,
    ),
  ];
  static const ShopItem _safeHouseItem = ShopItem(
    id: 'safe_house',
    name: 'Safe House Lease',
    description: 'Claim a rest spot on this street for healing and recovery.',
    icon: Icons.home_work_rounded,
    accentColor: Colors.lightBlueAccent,
    cost: 450,
    isSafeHouse: true,
  );

  static const List<ShopItem> _weaponItems = [
    ShopItem(
      id: 'rust_pipe',
      name: 'Rust Pipe',
      description: 'Basic street weapon. Stored for a future combat update.',
      icon: Icons.hardware,
      accentColor: Colors.blueGrey,
      cost: 120,
      isWeapon: true,
      streetTypes: [StreetType.ghetto, StreetType.industrial],
    ),
    ShopItem(
      id: 'dock_cleaver',
      name: 'Dock Cleaver',
      description: 'Harbor-side blade. Stored for a future combat update.',
      icon: Icons.content_cut,
      accentColor: Colors.tealAccent,
      cost: 220,
      isWeapon: true,
      streetTypes: [StreetType.harbor, StreetType.chinatown],
    ),
    ShopItem(
      id: 'security_baton',
      name: 'Security Baton',
      description: 'Downtown weapon. Stored for future loadouts.',
      icon: Icons.sports_martial_arts,
      accentColor: Colors.amberAccent,
      cost: 260,
      isWeapon: true,
      streetTypes: [StreetType.downtown, StreetType.entertainment],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final streetType = currentStreet.streetType;
    final weaponItems = streetType == null
        ? <ShopItem>[]
        : _weaponItems
              .where((item) => item.streetTypes.contains(streetType))
              .toList();
    final allItems = [..._items, _safeHouseItem, ...weaponItems];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 112, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BLACK MARKET SHOP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFE24B4A).withValues(alpha: 0.8),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.amberAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amberAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${gameController.money}',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Foods are stocked separately. Weapons are collected now for future combat.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                final item = allItems[index];
                final ownsSafeHouse =
                    currentStreet.id == spawnStreetId ||
                    gameController.hasSafeHouseAt(currentStreet.id);
                final owned = item.isSafeHouse
                    ? ownsSafeHouse
                    : item.isWeapon
                    ? gameController.ownsWeapon(item.id)
                    : false;
                final bool canAfford =
                    gameController.money >= item.cost && !owned;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                    boxShadow: [
                      BoxShadow(
                        color: item.accentColor.withValues(alpha: 0.05),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: item.accentColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          color: item.accentColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.description,
                              style: TextStyle(
                                color: Colors.white70.withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (item.healthRestore > 0)
                                  _buildStatBadge(
                                    Icons.favorite,
                                    Colors.redAccent,
                                    '+${item.healthRestore} HP',
                                  ),
                                if (item.staminaRestore > 0)
                                  _buildStatBadge(
                                    Icons.bolt,
                                    Colors.cyanAccent,
                                    '+${item.staminaRestore.toInt()} Stam',
                                  ),
                                if (item.hungerRestore > 0)
                                  _buildStatBadge(
                                    Icons.restaurant,
                                    Colors.orangeAccent,
                                    '+${item.hungerRestore.toInt()} Food',
                                  ),
                                if (item.isFood)
                                  _buildStatBadge(
                                    Icons.inventory_2,
                                    item.accentColor,
                                    'Stock x${gameController.foodCount(item.id)}',
                                  ),
                                if (item.isSafeHouse)
                                  _buildStatBadge(
                                    Icons.home,
                                    item.accentColor,
                                    'Street property',
                                  ),
                                if (item.isWeapon)
                                  _buildStatBadge(
                                    Icons.lock_clock,
                                    item.accentColor,
                                    'Future use',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            owned ? 'OWNED' : '\$${item.cost}',
                            style: TextStyle(
                              color: owned
                                  ? item.accentColor
                                  : canAfford
                                  ? Colors.amberAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item.accentColor,
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: Colors.white12,
                              disabledForegroundColor: Colors.white24,
                              minimumSize: const Size(60, 30),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: canAfford
                                ? () {
                                    final success = _buyShopItem(item);
                                    if (success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'PURCHASED ${item.name.toUpperCase()}',
                                          ),
                                          duration: const Duration(
                                            milliseconds: 800,
                                          ),
                                          backgroundColor: item.accentColor
                                              .withValues(alpha: 0.8),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            child: Text(
                              owned
                                  ? 'OWNED'
                                  : item.isSafeHouse
                                  ? 'LEASE'
                                  : 'BUY',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _buyShopItem(ShopItem item) {
    if (item.isSafeHouse) {
      return gameController.buySafeHouse(
        streetId: currentStreet.id,
        cost: item.cost,
      );
    }
    if (item.isWeapon) {
      return gameController.buyWeapon(weaponId: item.id, cost: item.cost);
    }
    if (item.isFood) {
      return gameController.buyFoodSupply(
        foodId: item.id,
        cost: item.cost,
        stamina: item.staminaRestore,
        hunger: item.hungerRestore,
        health: item.healthRestore,
      );
    }
    return gameController.buyItem(
      cost: item.cost,
      stamina: item.staminaRestore,
      hunger: item.hungerRestore,
      health: item.healthRestore,
    );
  }

  Widget _buildStatBadge(IconData icon, Color color, String text) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
