class AssetPaths {
  AssetPaths._();

  // Player
  static const String julieSpritesheet = 'sprites/julie.png';

  // Room easter egg
  static const String portraitSprite = 'sprites/portrait.png';

  // Cats (1 chat = 1 image)
  static const String cat1 = 'sprites/chat1.png';
  static const String cat2 = 'sprites/chat2.png';
  static const String cat3 = 'sprites/chat3.png';
  static const String cat4 = 'sprites/chat4.png';
  static const String cat5 = 'sprites/chat5.png';
  static const String cat6 = 'sprites/chat6.png';

  static const List<String> cats = [
    cat1,
    cat2,
    cat3,
    cat4,
    cat5,
    cat6,
  ];

  // World
  static const String pedestalSprite = 'sprites/pedestal_book.png';
  static const String doorSprite = 'sprites/doors.png';

  // Rooms (Flame path)
  static const List<String> rooms = [
    'sprites/room1.png',
    'sprites/room2.png',
    'sprites/room3.png',
    'sprites/room4.png',
    'sprites/room5.png',
    'sprites/room6.png',
    'sprites/room7.png',
    'sprites/room8.png',
    'sprites/room9.png',
    'sprites/room10.png',
    'sprites/room11.png',
  ];

  static String roomForLevel(int level) {
    final i = (level - 1).clamp(0, rooms.length - 1);
    return rooms[i];
  }

  // Wall
  static const String wallSheet = 'sprites/medieval_walls.png';

  // Sol
  static const String floorSheet = 'sprites/floor1.png';

  // Data
  static const String doorsJson = 'assets/data/doors.json';

  /// UTILITAIRE POUR FLUTTER UI
  /// Convertit un chemin Flame -> chemin Flutter
  static String ui(String flamePath) => 'assets/images/$flamePath';
}
