import 'package:flutter/foundation.dart';
import 'package:flame/components.dart';

/// Centralized input controller. Both DPad overlay and keyboard feed into this.
class InputController extends ChangeNotifier {
  final Set<LogicalDirection> _activeDirections = {};

  void press(LogicalDirection direction) {
    _activeDirections.add(direction);
    notifyListeners();
  }

  void release(LogicalDirection direction) {
    _activeDirections.remove(direction);
    notifyListeners();
  }

  void releaseAll() {
    _activeDirections.clear();
    notifyListeners();
  }

  bool get isMoving => _activeDirections.isNotEmpty;

  /// Returns a normalized movement vector.
  Vector2 get movementVector {
    double dx = 0;
    double dy = 0;

    if (_activeDirections.contains(LogicalDirection.left)) dx -= 1;
    if (_activeDirections.contains(LogicalDirection.right)) dx += 1;
    if (_activeDirections.contains(LogicalDirection.up)) dy -= 1;
    if (_activeDirections.contains(LogicalDirection.down)) dy += 1;

    final vec = Vector2(dx, dy);
    if (vec.length > 0) vec.normalize();
    return vec;
  }

  /// Returns the last horizontal direction for sprite animation selection.
  LogicalDirection get lastHorizontalDirection {
    if (_activeDirections.contains(LogicalDirection.left)) {
      return LogicalDirection.left;
    }
    if (_activeDirections.contains(LogicalDirection.right)) {
      return LogicalDirection.right;
    }
    return LogicalDirection.right; // default
  }
}

enum LogicalDirection { up, down, left, right }
