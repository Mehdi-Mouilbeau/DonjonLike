import 'dart:convert';
import 'package:flutter/services.dart';

import '../../core/constants/asset_paths.dart';
import '../models/door_model.dart';

/// Loads door data from the bundled JSON asset.
class DoorLocalDatasource {
  Future<List<DoorModel>> loadDoorsFromAsset() async {
    final jsonString = await rootBundle.loadString(AssetPaths.doorsJson);
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => DoorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
