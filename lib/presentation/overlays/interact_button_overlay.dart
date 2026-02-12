import 'package:flutter/material.dart';

/// Floating "Interact" button shown when the player is near a door or pedestal.
class InteractButtonOverlay extends StatelessWidget {
  final VoidCallback onInteract;

  const InteractButtonOverlay({super.key, required this.onInteract});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32,
      right: 32,
      child: FloatingActionButton.extended(
        heroTag: 'interact',
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.black,
        onPressed: onInteract,
        icon: const Icon(Icons.touch_app),
        label: const Text('Interagir'),
      ),
    );
  }
}
