// import 'package:flame/collisions.dart';
// import 'package:flame/components.dart';
// import 'package:flame/sprite.dart';

// import '../../core/constants/asset_paths.dart';
// import '../rpg_game.dart';

// class WallTileComponent extends SpriteComponent
//     with HasGameReference<RPGGame>, CollisionCallbacks {
//   final int row; // 0-based
//   final int col; // 0-based

//   WallTileComponent({
//     required Vector2 position,
//     required Vector2 size,
//     required this.row,
//     required this.col,
//     bool flipX = false,
//     bool flipY = false,
//     int priority = 100,
//   }) : super(
//           position: position,
//           size: size,
//           priority: priority,
//         ) {
//     if (flipX) scale.x = -1;
//     if (flipY) scale.y = -1;
//   }

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();

//     final image = await game.images.load(AssetPaths.wallSheet);

//     // Sheet 4x4
//     final tileW = (image.width / 4).floorToDouble();
//     final tileH = (image.height / 4).floorToDouble();

//     final sheet = SpriteSheet(
//       image: image,
//       srcSize: Vector2(tileW, tileH),
//     );

//     sprite = sheet.getSprite(row, col);

//     add(RectangleHitbox()..collisionType = CollisionType.passive);
//   }
// }
