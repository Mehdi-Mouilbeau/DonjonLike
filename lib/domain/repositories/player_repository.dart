/// Abstract repository for player data.
abstract class PlayerRepository {
  String? getPlayerName();
  Future<void> setPlayerName(String name);
}
