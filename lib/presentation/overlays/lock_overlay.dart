import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';

/// Code entry overlay for a locked door.
class LockOverlay extends StatefulWidget {
  final GameController gameController;

  const LockOverlay({super.key, required this.gameController});

  @override
  State<LockOverlay> createState() => _LockOverlayState();
}

class _LockOverlayState extends State<LockOverlay> {
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.gameController.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.gameController.removeListener(_onControllerUpdate);
    _codeController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _submit() {
    widget.gameController.submitCode(_codeController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final gc = widget.gameController;
    final door = gc.activeDoor;
    if (door == null) return const SizedBox.shrink();

    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                door.label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Icon(Icons.lock, size: 48),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 12,
                ),
                decoration: const InputDecoration(
                  hintText: '_ _ _ _',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              if (gc.lockErrorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  gc.lockErrorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: gc.closeLock,
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Valider'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
