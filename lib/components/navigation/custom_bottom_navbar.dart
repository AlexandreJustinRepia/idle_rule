import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFFE24B4A),
        unselectedItemColor: const Color(0xFF666666),
        currentIndex: currentIndex,
        onTap: onTap,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 11,
        ),
        items: [
          _buildNavItem(Icons.location_on, 'Street', 0),
          _buildNavItem(Icons.fitness_center, 'Gym', 1),
          _buildNavItem(Icons.shopping_cart, 'Shop', 2),
          _buildNavItem(Icons.map, 'Turfs', 3),
          _buildNavItem(Icons.group, 'Gangs', 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData iconData, String label, int index) {
    final bool isActive = currentIndex == index;
    
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE24B4A).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          iconData,
          size: isActive ? 26 : 22,
          color: isActive ? const Color(0xFFE24B4A) : const Color(0xFF666666),
        ),
      ),
      label: label,
    );
  }
}
