import 'package:flutter/material.dart';

import '../../game/input/input_controller.dart';

/// Semi-transparent D-Pad for mobile controls.
class DPadOverlay extends StatelessWidget {
  final InputController inputController;

  const DPadOverlay({super.key, required this.inputController});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32,
      left: 32,
      child: SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          children: [
            // Up
            Positioned(
              top: 0,
              left: 50,
              child: _DPadButton(
                icon: Icons.arrow_upward,
                direction: LogicalDirection.up,
                inputController: inputController,
              ),
            ),
            // Down
            Positioned(
              bottom: 0,
              left: 50,
              child: _DPadButton(
                icon: Icons.arrow_downward,
                direction: LogicalDirection.down,
                inputController: inputController,
              ),
            ),
            // Left
            Positioned(
              top: 50,
              left: 0,
              child: _DPadButton(
                icon: Icons.arrow_back,
                direction: LogicalDirection.left,
                inputController: inputController,
              ),
            ),
            // Right
            Positioned(
              top: 50,
              right: 0,
              child: _DPadButton(
                icon: Icons.arrow_forward,
                direction: LogicalDirection.right,
                inputController: inputController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DPadButton extends StatelessWidget {
  final IconData icon;
  final LogicalDirection direction;
  final InputController inputController;

  const _DPadButton({
    required this.icon,
    required this.direction,
    required this.inputController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => inputController.press(direction),
      onTapUp: (_) => inputController.release(direction),
      onTapCancel: () => inputController.release(direction),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
