import 'package:flutter/material.dart';
import '../ui/profile_edit_modal.dart';

class CustomNavbar extends StatefulWidget implements PreferredSizeWidget {
  final int money;
  const CustomNavbar({super.key, this.money = 0});

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _CustomNavbarState extends State<CustomNavbar> {
  String _characterName = 'Player';
  IconData _profilePic = Icons.person;

  void _showProfileModal() {
    showDialog(
      context: context,
      builder: (context) {
        return ProfileEditModal(
          initialName: _characterName,
          initialIcon: _profilePic,
          onSave: (newName, newIcon) {
            setState(() {
              _characterName = newName;
              _profilePic = newIcon;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_profilePic, color: Colors.white),
                      onPressed: _showProfileModal,
                    ),
                    Flexible(
                      child: Text(
                        _characterName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE24B4A).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.attach_money, size: 18, color: Color(0xFFE24B4A)),
                    const SizedBox(width: 4),
                    Text(
                      widget.money.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
