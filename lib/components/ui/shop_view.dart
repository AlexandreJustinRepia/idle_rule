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

// All items catalogue
const List<ShopItem> _foodItems = [
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
];

const List<ShopItem> _medicalItems = [
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

const ShopItem _safeHouseItem = ShopItem(
  id: 'safe_house',
  name: 'Safe House Lease',
  description: 'Claim a rest spot on this street for healing and recovery.',
  icon: Icons.home_work_rounded,
  accentColor: Colors.lightBlueAccent,
  cost: 450,
  isSafeHouse: true,
);

const List<ShopItem> _weaponItems = [
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

// Main widget
class ShopView extends StatefulWidget {
  final GameController gameController;
  final TurfTerritory currentStreet;
  final String spawnStreetId;

  const ShopView({
    super.key,
    required this.gameController,
    required this.currentStreet,
    required this.spawnStreetId,
  });

  @override
  State<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ShopItem> get _availableWeapons {
    final streetType = widget.currentStreet.streetType;
    if (streetType == null) return [];
    return _weaponItems
        .where((w) => w.streetTypes.contains(streetType))
        .toList();
  }

  bool _isOwned(ShopItem item) {
    if (item.isSafeHouse) {
      return widget.currentStreet.id == widget.spawnStreetId ||
          widget.gameController.hasSafeHouseAt(widget.currentStreet.id);
    }
    if (item.isWeapon) return widget.gameController.ownsWeapon(item.id);
    return false;
  }

  bool _buyShopItem(ShopItem item) {
    if (item.isSafeHouse) {
      return widget.gameController.buySafeHouse(
        streetId: widget.currentStreet.id,
        cost: item.cost,
      );
    }
    if (item.isWeapon) {
      return widget.gameController
          .buyWeapon(weaponId: item.id, cost: item.cost);
    }
    if (item.isFood) {
      return widget.gameController.buyFoodSupply(
        foodId: item.id,
        cost: item.cost,
        stamina: item.staminaRestore,
        hunger: item.hungerRestore,
        health: item.healthRestore,
      );
    }
    return widget.gameController.buyItem(
      cost: item.cost,
      stamina: item.staminaRestore,
      hunger: item.hungerRestore,
      health: item.healthRestore,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameController,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 112, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                  _MoneyBadge(amount: widget.gameController.money),
                ],
              ),
              const SizedBox(height: 12),
              // Tab bar
              _ShopTabBar(controller: _tabController),
              const SizedBox(height: 12),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ItemsPage(
                      items: _foodItems,
                      emptyLabel: 'No food available here.',
                      isOwned: _isOwned,
                      onBuy: _buyShopItem,
                      gameController: widget.gameController,
                    ),
                    _ItemsPage(
                      items: _medicalItems,
                      emptyLabel: 'No medical supplies available here.',
                      isOwned: _isOwned,
                      onBuy: _buyShopItem,
                      gameController: widget.gameController,
                    ),
                    _ItemsPage(
                      items: [_safeHouseItem],
                      emptyLabel: 'No safe house available here.',
                      isOwned: _isOwned,
                      onBuy: _buyShopItem,
                      gameController: widget.gameController,
                    ),
                    _ItemsPage(
                      items: _availableWeapons,
                      emptyLabel: 'No weapons available on this street type.',
                      isOwned: _isOwned,
                      onBuy: _buyShopItem,
                      gameController: widget.gameController,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Money badge
class _MoneyBadge extends StatelessWidget {
  final int amount;
  const _MoneyBadge({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on,
              color: Colors.amberAccent, size: 18),
          const SizedBox(width: 4),
          Text(
            '$amount',
            style: const TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom tab bar
class _ShopTabBar extends StatelessWidget {
  final TabController controller;
  const _ShopTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE24B4A), Color(0xFFC0392B)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 1,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
        tabs: const [
          Tab(
            height: 38,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fastfood, size: 14),
                SizedBox(width: 5),
                Text('FOOD'),
              ],
            ),
          ),
          Tab(
            height: 38,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.healing, size: 14),
                SizedBox(width: 5),
                Text('MEDICAL'),
              ],
            ),
          ),
          Tab(
            height: 38,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home_work_rounded, size: 14),
                SizedBox(width: 5),
                Text('SAFE HOUSE'),
              ],
            ),
          ),
          Tab(
            height: 38,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hardware, size: 14),
                SizedBox(width: 5),
                Text('WEAPONS'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Items page
class _ItemsPage extends StatelessWidget {
  final List<ShopItem> items;
  final String emptyLabel;
  final bool Function(ShopItem) isOwned;
  final bool Function(ShopItem) onBuy;
  final GameController gameController;

  const _ItemsPage({
    required this.items,
    required this.emptyLabel,
    required this.isOwned,
    required this.onBuy,
    required this.gameController,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.remove_shopping_cart,
                color: Colors.white24, size: 40),
            const SizedBox(height: 12),
            Text(
              emptyLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _ShopCard(
          item: items[index],
          owned: isOwned(items[index]),
          gameController: gameController,
          onBuy: () {
            final ok = onBuy(items[index]);
            if (ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('PURCHASED ${items[index].name.toUpperCase()}'),
                  duration: const Duration(milliseconds: 800),
                  backgroundColor:
                      items[index].accentColor.withValues(alpha: 0.85),
                ),
              );
            }
          },
        );
      },
    );
  }
}

// Individual shop card
class _ShopCard extends StatelessWidget {
  final ShopItem item;
  final bool owned;
  final GameController gameController;
  final VoidCallback onBuy;

  const _ShopCard({
    required this.item,
    required this.owned,
    required this.gameController,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = gameController.money >= item.cost && !owned;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131317),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: owned
              ? item.accentColor.withValues(alpha: 0.45)
              : Colors.white10,
          width: owned ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: item.accentColor.withValues(alpha: owned ? 0.1 : 0.04),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card top: icon + name + price
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: item.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: item.accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Icon(item.icon, color: item.accentColor, size: 28),
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
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
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
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    if (item.isFood) ...[
                      const SizedBox(height: 2),
                      Text(
                        'x${gameController.foodCount(item.id)} in stock',
                        style: TextStyle(
                          color: item.accentColor.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Stat badges row
          if (item.healthRestore > 0 ||
              item.staminaRestore > 0 ||
              item.hungerRestore > 0 ||
              item.isSafeHouse ||
              item.isWeapon)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (item.healthRestore > 0)
                    _StatBadge(Icons.favorite, Colors.redAccent,
                        '+${item.healthRestore} HP'),
                  if (item.staminaRestore > 0)
                    _StatBadge(Icons.bolt, Colors.cyanAccent,
                        '+${item.staminaRestore.toInt()} Stamina'),
                  if (item.hungerRestore > 0)
                    _StatBadge(Icons.restaurant, Colors.orangeAccent,
                        '+${item.hungerRestore.toInt()} Hunger'),
                  if (item.isSafeHouse)
                    _StatBadge(
                        Icons.home, item.accentColor, 'Street property'),
                  if (item.isWeapon)
                    _StatBadge(
                        Icons.lock_clock, item.accentColor, 'Future use'),
                ],
              ),
            ),

          // Buy button
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: owned
                      ? Colors.white10
                      : canAfford
                          ? item.accentColor
                          : Colors.white10,
                  foregroundColor: owned
                      ? Colors.white38
                      : canAfford
                          ? Colors.black
                          : Colors.white24,
                  disabledBackgroundColor: Colors.white10,
                  disabledForegroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: canAfford ? onBuy : null,
                child: Text(
                  owned
                      ? 'OWNED'
                      : item.isSafeHouse
                          ? 'LEASE  \$${item.cost}'
                          : 'BUY  \$${item.cost}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Stat badge
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _StatBadge(this.icon, this.color, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
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
