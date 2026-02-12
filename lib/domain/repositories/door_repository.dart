import '../entities/door.dart';

/// Abstract repository for door data operations.
abstract class DoorRepository {
  /// Load all doors from the data source and merge persisted status.
  Future<List<Door>> loadDoors();

  /// Persist the status of a single door.
  Future<void> saveDoorStatus(Door door);

  /// Get the global last door entry date.
  DateTime? getLastDoorEntryDate();

  /// Set the global last door entry date.
  Future<void> setLastDoorEntryDate(DateTime date);

  /// Mark a hint as unlocked for a door.
  Future<void> unlockHint(String doorId);

  /// Check if a hint is unlocked.
  bool isHintUnlocked(String doorId);
}
