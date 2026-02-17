import 'dart:ui';
import 'package:flame/components.dart';

///  Change ça ici : 2.0 ou 3.0
const double kLevelScale = 4.5;

/// A wall segment definition for level layout.
class WallDef {
  final double x;
  final double y;
  final double w;
  final double h;

  const WallDef(this.x, this.y, this.w, this.h);

  WallDef scaled(double s) => WallDef(x * s, y * s, w * s, h * s);
}

/// A door placement definition within a level.
class DoorPlacement {
  final double x;
  final double y;

  const DoorPlacement(this.x, this.y);

  DoorPlacement scaled(double s) => DoorPlacement(x * s, y * s);
}

/// Complete level layout definition.
class LevelLayout {
  final int level;
  final String name;
  final double width;
  final double height;
  final Color floorColor;
  final Color wallColor;
  final double wallThickness;
  final List<WallDef> walls;

  /// ✅ 1 seule porte par niveau (objectif du niveau)
  final List<DoorPlacement> doorPlacements;

  /// ✅ spawn cohérent (début du niveau)
  final Vector2 playerSpawn;

  const LevelLayout({
    required this.level,
    required this.name,
    required this.width,
    required this.height,
    required this.floorColor,
    required this.wallColor,
    this.wallThickness = 20.0,
    required this.walls,
    required this.doorPlacements,
    required this.playerSpawn,
  });

  LevelLayout scaled(double s) {
    return LevelLayout(
      level: level,
      name: name,
      width: width * s,
      height: height * s,
      floorColor: floorColor,
      wallColor: wallColor,
      wallThickness: wallThickness * s,
      walls: walls.map((w) => w.scaled(s)).toList(),
      doorPlacements: doorPlacements.map((d) => d.scaled(s)).toList(),
      playerSpawn: playerSpawn * s,
    );
  }
}

///  Tu écris tes niveaux en "taille normale" ici (comme tu l’as fait).
final List<LevelLayout> baseLevels = [
  // ─────────────────────────────────────────────────────────
  // LEVEL 1: Simple Hallway
  // Objectif: aller jusqu'au bout à droite.
  // ─────────────────────────────────────────────────────────
  LevelLayout(
    level: 1,
    name: 'Le Couloir Ancien',
    width: 600,
    height: 200,
    floorColor: const Color(0xFF37474F),
    wallColor: const Color(0xFF546E7A),
    walls: const [
      WallDef(0, 0, 600, 20), // top
      WallDef(0, 180, 600, 20), // bottom
      WallDef(0, 0, 20, 200), // left
      WallDef(580, 0, 20, 200), // right
    ],
    doorPlacements: const [
      DoorPlacement(520, 45),
    ],
    playerSpawn: Vector2(80, 150),
  ),

  // ─────────────────────────────────────────────────────────
// LEVEL 2: Couloir en L (refait)
// Plus haut, moins large, couloir large (anti-collisions)
// ─────────────────────────────────────────────────────────
  LevelLayout(
    level: 2,
    name: 'Couloir en L',
    width: 520,
    height: 900,
    floorColor: const Color(0xFF000000),
    wallColor: const Color(0xFF000000),
    walls: const [
      // ── murs extérieurs (épaisseur 20 comme les autres niveaux)
      WallDef(0, 0, 520, 20), // top
      WallDef(0, 880, 520, 20), // bottom
      WallDef(0, 0, 20, 900), // left
      WallDef(500, 0, 20, 900), // right

      // ── “bloc plein” intérieur qui crée le couloir en L
      // Laisse une bande de 180px en bas + 180px à droite (zone walkable)
      WallDef(20, 20, 300, 680),
    ],

    // Porte en haut du couloir vertical (à droite)
    doorPlacements: const [
      DoorPlacement(410, 70),
    ],

    // Spawn dans le couloir horizontal (en bas à gauche)
    playerSpawn: Vector2(80, 790),
  ),

  // ─────────────────────────────────────────────────────────
  // LEVEL 3: T-Junction
  // Objectif: porte en bas du "T".
  // ─────────────────────────────────────────────────────────
  LevelLayout(
    level: 3,
    name: 'Le Carrefour en T',
    width: 800,
    height: 600,
    floorColor: const Color(0xFF3E2723),
    wallColor: const Color(0xFF5D4037),
    walls: const [
      WallDef(0, 0, 800, 24),
      WallDef(0, 0, 24, 220),
      WallDef(776, 0, 24, 220),
      WallDef(0, 196, 300, 24),
      WallDef(500, 196, 300, 24),
      WallDef(300, 220, 24, 380),
      WallDef(476, 220, 24, 380),
      WallDef(300, 576, 200, 24),
    ],
    doorPlacements: const [
      DoorPlacement(400, 520),
    ],
    playerSpawn: Vector2(400, 120),
  ),

  // ─────────────────────────────────────────────────────────
  // LEVEL 4: Cross / Plus
  // Objectif: porte en haut.
  // ─────────────────────────────────────────────────────────
  LevelLayout(
    level: 4,
    name: 'La Croix des Ombres',
    width: 500,
    height: 500,
    floorColor: const Color(0xFF1A237E),
    wallColor: const Color(0xFF283593),
    walls: const [
      WallDef(180, 0, 20, 180),
      WallDef(300, 0, 20, 180),
      WallDef(180, 0, 140, 20),
      WallDef(180, 320, 20, 180),
      WallDef(300, 320, 20, 180),
      WallDef(180, 480, 140, 20),
      WallDef(0, 180, 180, 20),
      WallDef(0, 300, 180, 20),
      WallDef(0, 180, 20, 140),
      WallDef(320, 180, 180, 20),
      WallDef(320, 300, 180, 20),
      WallDef(480, 180, 20, 140),
    ],
    doorPlacements: const [
      DoorPlacement(250, 40),
    ],
    playerSpawn: Vector2(250, 440),
  ),

  // ─────────────────────────────────────────────────────────
  // LEVEL 5: Zigzag (Serpent)
  // Objectif: porte vers la fin (bas).
  // ─────────────────────────────────────────────────────────
  LevelLayout(
    level: 5,
    name: 'Le Serpent de Pierre',
    width: 600,
    height: 500,
    floorColor: const Color(0xFF004D40),
    wallColor: const Color(0xFF00695C),
    walls: const [
      WallDef(0, 0, 600, 20),
      WallDef(0, 0, 20, 120),
      WallDef(0, 100, 480, 20),
      WallDef(580, 0, 20, 220),
      WallDef(120, 200, 480, 20),
      WallDef(0, 100, 20, 220),
      WallDef(0, 300, 480, 20),
      WallDef(580, 200, 20, 220),
      WallDef(120, 400, 480, 20),
      WallDef(0, 300, 20, 200),
      WallDef(0, 480, 600, 20),
      WallDef(580, 400, 20, 100),
    ],
    doorPlacements: const [
      DoorPlacement(300, 445),
    ],
    playerSpawn: Vector2(50, 55),
  ),

  // ─────────────────────────────────────────────────────────
  // LEVEL 6: Arena
  // Objectif: porte en haut.
  // ─────────────────────────────────────────────────────────
  LevelLayout(
    level: 6,
    name: "L'Arene Oubliee",
    width: 500,
    height: 500,
    floorColor: const Color(0xFF4E342E),
    wallColor: const Color(0xFF6D4C41),
    walls: const [
      WallDef(0, 0, 500, 20),
      WallDef(0, 480, 500, 20),
      WallDef(0, 0, 20, 500),
      WallDef(480, 0, 20, 500),
      WallDef(140, 140, 40, 40),
      WallDef(320, 140, 40, 40),
      WallDef(140, 320, 40, 40),
      WallDef(320, 320, 40, 40),
      WallDef(220, 220, 60, 60),
    ],
    doorPlacements: const [
      DoorPlacement(250, 50),
    ],
    playerSpawn: Vector2(250, 440),
  ),

  // ─────────────────────────────────────────────────────────
  // LEVEL 7: Spiral
  // Objectif: porte proche du centre.
  // ─────────────────────────────────────────────────────────
  LevelLayout(
    level: 7,
    name: 'La Spirale Eternelle',
    width: 600,
    height: 600,
    floorColor: const Color(0xFF311B92),
    wallColor: const Color(0xFF4527A0),
    walls: const [
      WallDef(0, 0, 600, 20),
      WallDef(0, 0, 20, 600),
      WallDef(0, 580, 600, 20),
      WallDef(580, 100, 20, 500),
      WallDef(100, 100, 400, 20),
      WallDef(100, 100, 20, 400),
      WallDef(100, 480, 480, 20),
      WallDef(200, 200, 20, 300),
      WallDef(200, 200, 200, 20),
      WallDef(380, 200, 20, 200),
      WallDef(280, 300, 20, 100),
    ],
    doorPlacements: const [
      DoorPlacement(340, 260),
    ],
    playerSpawn: Vector2(50, 550),
  ),

  // ─────────────────────────────────────────────────────────
  // LEVEL 8: Diamond
  // Objectif: passage haut.
  // ─────────────────────────────────────────────────────────
  LevelLayout(
    level: 8,
    name: 'Le Diamant Brise',
    width: 500,
    height: 500,
    floorColor: const Color(0xFF0D47A1),
    wallColor: const Color(0xFF1565C0),
    walls: const [
      WallDef(0, 0, 500, 20),
      WallDef(0, 480, 500, 20),
      WallDef(0, 0, 20, 500),
      WallDef(480, 0, 20, 500),
      WallDef(200, 60, 20, 120),
      WallDef(100, 160, 120, 20),
      WallDef(280, 60, 20, 120),
      WallDef(280, 160, 120, 20),
      WallDef(100, 320, 120, 20),
      WallDef(200, 320, 20, 120),
      WallDef(280, 320, 120, 20),
      WallDef(280, 320, 20, 120),
      WallDef(220, 200, 60, 20),
      WallDef(220, 280, 60, 20),
    ],
    doorPlacements: const [
      DoorPlacement(250, 100),
    ],
    playerSpawn: Vector2(250, 450),
  ),

  // ─────────────────────────────────────────────────────────
  // LEVEL 9: Maze
  // Objectif: bas-droite.
  // ─────────────────────────────────────────────────────────
  LevelLayout(
    level: 9,
    name: 'Le Labyrinthe Maudit',
    width: 700,
    height: 700,
    floorColor: const Color(0xFF1B5E20),
    wallColor: const Color(0xFF2E7D32),
    walls: const [
      WallDef(0, 0, 700, 20),
      WallDef(0, 680, 700, 20),
      WallDef(0, 0, 20, 700),
      WallDef(680, 0, 20, 700),
      WallDef(100, 100, 200, 20),
      WallDef(400, 100, 200, 20),
      WallDef(20, 200, 150, 20),
      WallDef(250, 200, 20, 120),
      WallDef(350, 180, 20, 140),
      WallDef(450, 200, 170, 20),
      WallDef(100, 300, 170, 20),
      WallDef(350, 300, 250, 20),
      WallDef(20, 400, 200, 20),
      WallDef(300, 380, 20, 120),
      WallDef(400, 400, 200, 20),
      WallDef(100, 500, 150, 20),
      WallDef(350, 500, 20, 100),
      WallDef(450, 500, 160, 20),
      WallDef(20, 580, 250, 20),
      WallDef(450, 580, 160, 20),
    ],
    doorPlacements: const [
      DoorPlacement(550, 640),
    ],
    playerSpawn: Vector2(60, 60),
  ),

  // ─────────────────────────────────────────────────────────
  // LEVEL 10: Twin Rooms
  // Objectif: bas de la salle droite.
  // ─────────────────────────────────────────────────────────
  LevelLayout(
    level: 10,
    name: 'Les Salles Jumelles',
    width: 700,
    height: 350,
    floorColor: const Color(0xFF37474F),
    wallColor: const Color(0xFF455A64),
    walls: const [
      WallDef(0, 0, 300, 20),
      WallDef(0, 330, 300, 20),
      WallDef(0, 0, 20, 350),
      WallDef(280, 0, 20, 130),
      WallDef(280, 220, 20, 130),
      WallDef(400, 0, 300, 20),
      WallDef(400, 330, 300, 20),
      WallDef(680, 0, 20, 350),
      WallDef(400, 0, 20, 130),
      WallDef(400, 220, 20, 130),
      WallDef(280, 130, 140, 20),
      WallDef(280, 200, 140, 20),
      WallDef(100, 120, 40, 40),
      WallDef(180, 220, 40, 40),
      WallDef(500, 100, 40, 40),
      WallDef(600, 230, 40, 40),
    ],
    doorPlacements: const [
      DoorPlacement(550, 300),
    ],
    playerSpawn: Vector2(150, 280),
  ),

  // ─────────────────────────────────────────────────────────
  // LEVEL 11: Finale
  // Objectif: haut-droit.
  // ─────────────────────────────────────────────────────────
  LevelLayout(
    level: 11,
    name: 'Le Sanctuaire Final',
    width: 800,
    height: 800,
    floorColor: const Color(0xFF212121),
    wallColor: const Color(0xFF424242),
    walls: const [
      WallDef(0, 0, 800, 20),
      WallDef(0, 780, 800, 20),
      WallDef(0, 0, 20, 800),
      WallDef(780, 0, 20, 800),
      WallDef(100, 100, 300, 20),
      WallDef(500, 100, 200, 20),
      WallDef(100, 100, 20, 200),
      WallDef(200, 200, 200, 20),
      WallDef(500, 200, 20, 200),
      WallDef(600, 200, 100, 20),
      WallDef(20, 300, 120, 20),
      WallDef(220, 300, 200, 20),
      WallDef(600, 300, 120, 20),
      WallDef(100, 400, 120, 20),
      WallDef(300, 380, 20, 120),
      WallDef(400, 400, 120, 20),
      WallDef(600, 380, 20, 120),
      WallDef(20, 500, 200, 20),
      WallDef(300, 500, 200, 20),
      WallDef(600, 500, 120, 20),
      WallDef(100, 600, 20, 120),
      WallDef(200, 600, 300, 20),
      WallDef(600, 600, 120, 20),
      WallDef(200, 700, 20, 80),
      WallDef(300, 680, 200, 20),
      WallDef(600, 680, 20, 100),
      WallDef(700, 400, 20, 100),
      WallDef(700, 480, 80, 20),
      WallDef(50, 600, 20, 100),
    ],
    doorPlacements: const [
      DoorPlacement(650, 55),
    ],
    playerSpawn: Vector2(60, 60),
  ),
];

/// ✅ Ce que ton jeu doit utiliser : niveaux agrandis x2 (ou x3 si tu changes kLevelScale)
final List<LevelLayout> allLevels =
    baseLevels.map((l) => l.scaled(kLevelScale)).toList();
