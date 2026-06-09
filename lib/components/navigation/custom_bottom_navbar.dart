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
        color: Colors.black,
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
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
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
          _buildNavItem(Icons.map, 'Turfs', 2),
          _buildNavItem(Icons.group, 'Gangs', 3),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          iconData,
          size: isActive ? 28 : 24,
          color: isActive ? Colors.white : Colors.grey[600],
        ),
      ),
      label: label,
    );
  }
}
