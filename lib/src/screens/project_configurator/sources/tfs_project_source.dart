import 'dart:isolate';
import 'dart:typed_data';
import 'package:otstudio/src/models/sprite.dart';
import 'package:otstudio/src/models/texture.dart';
import 'package:otstudio/src/models/tile.dart';
import 'package:otstudio/src/models/atlas.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';
import 'package:image/image.dart' as img;
import 'package:bitmap/bitmap.dart';
import 'package:otstudio/src/models/area_map.dart';
import 'package:otstudio/src/models/map.dart' as modelMap;
import 'package:otstudio/src/models/assets.dart';
import 'package:otstudio/src/models/items.dart';
import 'package:otstudio/src/models/item.dart';
import 'package:otstudio/src/models/project.dart';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/screens/project_configurator/sources/source.dart';
import 'package:otstudio/src/serializers/disk_serializer.dart';
import 'package:otstudio/src/serializers/items/dat_serializer.dart';
import 'package:otstudio/src/serializers/items/spr_serializer.dart';
import 'package:otstudio/src/serializers/xml_serializer.dart';
import 'package:otstudio/src/serializers/items/otb_serializer.dart';
import 'package:otstudio/src/serializers/map/otbm_serializer.dart';

class TfsProjectSource extends Source<Project> {
  final String projectPath;
  double datProgress = 0;
  double sprProgress = 0;
  double xmlProgress = 0;
  double otbProgress = 0;
  double otbmProgress = 0;
  double mapIdsProgress = 0;

  TfsProjectSource({required this.projectPath});

  @override
  Future<Project> load(ProgressTracker<void> tracker) async {
    ReceivePort datPort = ReceivePort();
    ReceivePort sprPort = ReceivePort();
    ReceivePort xmlPort = ReceivePort();
    ReceivePort otbPort = ReceivePort();
    ReceivePort otbmPort = ReceivePort();
    ReceivePort mapIdsPort = ReceivePort();

    datPort.listen((progress) {
      datProgress = progress;
      updateProgress(tracker);
    });
    sprPort.listen((progress) {
      sprProgress = progress;
      updateProgress(tracker);
    });
    xmlPort.listen((progress) {
      xmlProgress = progress;
      updateProgress(tracker);
    });
    otbPort.listen((progress) {
      print('otbProgress $progress');
      otbProgress = progress;
      updateProgress(tracker);
    });
    otbmPort.listen((progress) {
      print('otbmProgress $progress');
      otbmProgress = progress;
      updateProgress(tracker);
    });
    mapIdsPort.listen((progress) {
      print('mapIdsProgress $progress');
      mapIdsProgress = progress;
      updateProgress(tracker);
    });

    DatDocument dat = await DatSerializer().deserialize(
        ProgressTracker<DiskSerializerDeserializePayload>(
            DiskSerializerDeserializePayload(join(projectPath, 'Tibia.dat')),
            datPort.sendPort));
    SprDocument spr = await SprSerializer().deserialize(
        ProgressTracker<DiskSerializerDeserializePayload>(
            DiskSerializerDeserializePayload(join(projectPath, 'Tibia.spr')),
            sprPort.sendPort));
    XmlDocument xml = await XmlSerializer().deserialize(
        ProgressTracker<DiskSerializerDeserializePayload>(
            DiskSerializerDeserializePayload(join(projectPath, 'items.xml')),
            xmlPort.sendPort));
    OtbDocument otb = await OtbSerializer().deserialize(
        ProgressTracker<DiskSerializerDeserializePayload>(
            DiskSerializerDeserializePayload(join(projectPath, 'items.otb')),
            otbPort.sendPort));

    Map<int, Item> items = Map();

    dat.items.values.forEach((DatItem datItem) {
      items[datItem.id] = Item(
          id: datItem.id,
          name: datItem.id.toString(),
          stackable: datItem.stackable,
          splash: datItem.splash,
          fluidContainer: datItem.fluidContainer,
          textures: getItemTextures(datItem.textures, spr.sprites));
    });

    Assets assets = Assets(items: Items(items: items));
    AreaMap map = await OtbmSerializer(items).deserialize(
        ProgressTracker<DiskSerializerDeserializePayload>(
            DiskSerializerDeserializePayload(join(projectPath, 'map.otbm')),
            otbmPort.sendPort));

    AreaMap mapWithProperIds =
        mapIds(map, otb, ProgressTracker<void>(null, mapIdsPort.sendPort));

    print('end');

    return Project(assets: assets, map: modelMap.Map(map: mapWithProperIds));
  }

  List<Texture> getItemTextures(
      DatTextures datTextures, Map<int, Sprite> sprites) {
    // List<int> spritesIds = datTextures.sprites.reversed.toList();

    int spriteIndex = 0;

    List<Texture> textures = [];

    for (int frame = 0; frame < datTextures.frames; frame++) {
      for (int patternZ = 0; patternZ < datTextures.patternsZ; patternZ++) {
        for (int patternY = 0; patternY < datTextures.patternsY; patternY++) {
          for (int patternX = 0; patternX < datTextures.patternsX; patternX++) {
            img.Image textureImage = img.Image(datTextures.width * Sprite.SIZE,
                datTextures.height * Sprite.SIZE);
            for (int layer = 0; layer < datTextures.layers; layer++) {
              for (int h = 0; h < datTextures.height; h++) {
                for (int w = 0; w < datTextures.width; w++) {
                  int spriteId = datTextures.sprites[spriteIndex++];
                  Sprite? sprite =
                      (spriteId >= 2 && spriteId <= sprites.length + 2)
                          ? sprites.values.firstWhere((s) => s.id == spriteId)
                          : null;
                  if (sprite != null) {
                    img.copyInto(
                      textureImage,
                      img.Image.fromBytes(
                          Sprite.SIZE, Sprite.SIZE, sprite.pixels),
                      dstX: (datTextures.width - w - 1) * Sprite.SIZE,
                      dstY: (datTextures.height - h - 1) * Sprite.SIZE,
                    );
                  }
                }
              }
            }

            Bitmap bitmap = Bitmap.fromHeadless(textureImage.width,
                textureImage.height, textureImage.getBytes());
            Uint8List headed = bitmap.buildHeaded();
            textures.add(Texture(
              width: textureImage.width.toDouble(),
              height: textureImage.height.toDouble(),
              bytes: textureImage.getBytes(),
              bitmap: headed,
            ));
          }
        }
      }
    }

    return textures;
  }

  AreaMap mapIds(AreaMap map, OtbDocument otb, ProgressTracker tracker) {
    AreaMap mapWithProperIds = AreaMap(width: map.width, height: map.height);
    Map<int, OtbItem> otbServerIdMap = Map.fromIterable(otb.items,
        key: (item) => item.serverId, value: (item) => item);
    map.tiles.values.toList().asMap().forEach((int index, Tile tile) {
      tile.items.forEach((Item item) {
        OtbItem otbItem = otbServerIdMap[item.id]!;
        Item itemWithProperId = Item(
            id: otbItem.clientId,
            name: item.name,
            stackable: item.stackable,
            splash: item.splash,
            fluidContainer: item.fluidContainer,
            textures: item.textures);
        mapWithProperIds.addItem(tile.position, itemWithProperId);
      });
      // print('tracker.progress');
      tracker.progress = (index + 1) / map.tiles.length;
    });
    return mapWithProperIds;
  }

  void updateProgress(ProgressTracker tracker) {
    tracker.progress = [
      datProgress,
      sprProgress,
      xmlProgress,
      otbProgress,
      otbmProgress,
      mapIdsProgress,
    ].average;
  }
}
