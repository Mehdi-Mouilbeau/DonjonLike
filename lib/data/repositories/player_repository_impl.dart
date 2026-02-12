import '../../core/services/storage_service.dart';
import '../../domain/repositories/player_repository.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  @override
  String? getPlayerName() => StorageService.getPlayerName();

  @override
  Future<void> setPlayerName(String name) =>
      StorageService.setPlayerName(name);
}
