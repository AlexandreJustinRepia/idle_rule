import 'package:flutter/material.dart';
import 'environment_painters.dart';
import 'graffiti_text.dart';

class StreetSceneLayer extends StatelessWidget {
  const StreetSceneLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          bottom: 60, 
          left: 0,
          right: 0,
          height: 170,
          child: CustomPaint(
            painter: BrickWallPainter(),
            child: Stack(
              children: [
                Positioned(top: 15, right: 60, child: _buildWindow()),
                Positioned(top: 60, left: 220, child: _buildWindow()),
                Positioned(left: 20, top: 0, bottom: 0, child: _buildPipes()),
                Positioned(left: 350, top: 0, bottom: 0, child: _buildPipes()),
                Positioned(
                  top: 50, 
                  left: 40, 
                  child: GraffitiText(
                    text: 'S-RANK\nONLY', 
                    angle: -0.15, 
                    color: Colors.redAccent,
                  ),
                ),
                Positioned(
                  top: 30, 
                  left: 280, 
                  child: GraffitiText(
                    text: 'IDLE', 
                    angle: 0.1, 
                    color: Colors.greenAccent, 
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: CustomPaint(painter: AsphaltPainter()),
        ),

        Positioned(right: 80, bottom: 60, child: _buildStreetLamp()),
        Positioned(left: 90, bottom: 55, child: _buildDumpster()),
        Positioned(left: 450, bottom: 60, child: _buildStreetLamp()),
      ],
    );
  }

  Widget _buildWindow() {
    return Container(
      width: 40,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(color: Colors.black87, width: 3),
      ),
      child: Column(
        children: [
          Expanded(child: Container(color: Colors.yellow.withValues(alpha: 0.1))),
          Container(height: 3, color: Colors.black87),
          Expanded(child: Container(color: Colors.yellow.withValues(alpha: 0.1))),
        ],
      ),
    );
  }

  Widget _buildPipes() {
    return Container(
      width: 10,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        border: const Border(
          left: BorderSide(color: Colors.black54, width: 1.5),
          right: BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStreetLamp() {
    return Column(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 20,
              ),
            ],
          ),
        ),
        Container(
          width: 8,
          height: 170,
          decoration: BoxDecoration(
            color: Colors.black87,
            border: Border.all(color: Colors.white10, width: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildDumpster() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 70,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.green[900],
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Center(child: Container(width: 55, height: 1.5, color: Colors.black54)),
        ),
        const SizedBox(width: 8),
        Icon(Icons.delete_outline, size: 28, color: Colors.grey[800]),
      ],
    );
  }
}
