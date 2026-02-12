import '../../core/services/storage_service.dart';
import '../../domain/entities/door.dart';
import '../../domain/repositories/door_repository.dart';
import '../datasources/door_local_datasource.dart';

class DoorRepositoryImpl implements DoorRepository {
  final DoorLocalDatasource _datasource;

  DoorRepositoryImpl({DoorLocalDatasource? datasource})
      : _datasource = datasource ?? DoorLocalDatasource();

  @override
  Future<List<Door>> loadDoors() async {
    final models = await _datasource.loadDoorsFromAsset();
    final doors = models.map((m) => m.toEntity()).toList();

    // Merge persisted status into each door.
    for (final door in doors) {
      final statusStr = StorageService.getDoorStatus(door.id);
      door.status = _parseDoorStatus(statusStr);
      door.lastAttemptDate = StorageService.getDoorLastAttemptDate(door.id);
      door.lastSuccessDate = StorageService.getDoorLastSuccessDate(door.id);
    }

    return doors;
  }

  @override
  Future<void> saveDoorStatus(Door door) async {
    await StorageService.setDoorStatus(door.id, door.status.name);
    if (door.lastAttemptDate != null) {
      await StorageService.setDoorLastAttemptDate(
          door.id, door.lastAttemptDate!);
    }
    if (door.lastSuccessDate != null) {
      await StorageService.setDoorLastSuccessDate(
          door.id, door.lastSuccessDate!);
    }
  }

  @override
  DateTime? getLastDoorEntryDate() =>
      StorageService.getLastDoorEntryDate();

  @override
  Future<void> setLastDoorEntryDate(DateTime date) =>
      StorageService.setLastDoorEntryDate(date);

  @override
  Future<void> unlockHint(String doorId) =>
      StorageService.setHintUnlocked(doorId);

  @override
  bool isHintUnlocked(String doorId) =>
      StorageService.isHintUnlocked(doorId);

  DoorStatus _parseDoorStatus(String status) {
    switch (status) {
      case 'opened':
        return DoorStatus.opened;
      case 'succeeded':
        return DoorStatus.succeeded;
      case 'failed':
        return DoorStatus.failed;
      default:
        return DoorStatus.locked;
    }
  }
}
