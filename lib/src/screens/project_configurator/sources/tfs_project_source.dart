import 'dart:isolate';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';
import 'package:otstudio/src/models/area_map.dart';
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

  TfsProjectSource({required this.projectPath});

  @override
  Future<Project> load(ProgressTracker<void> tracker) async {
    ReceivePort datPort = ReceivePort();
    ReceivePort sprPort = ReceivePort();
    ReceivePort xmlPort = ReceivePort();
    ReceivePort otbPort = ReceivePort();
    ReceivePort otbmPort = ReceivePort();

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
      otbProgress = progress;
      updateProgress(tracker);
    });
    otbmPort.listen((progress) {
      otbmProgress = progress;
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

    dat.items.forEach((DatItem datItem) {
      items[datItem.id] = Item(
          id: datItem.id,
          name: datItem.id.toString(),
          stackable: datItem.stackable,
          splash: datItem.splash,
          fluidContainer: datItem.fluidContainer);
    });

    Assets assets = Assets(items: Items(items: items));
    AreaMap map = await OtbmSerializer(items).deserialize(
        ProgressTracker<DiskSerializerDeserializePayload>(
            DiskSerializerDeserializePayload(join(projectPath, 'map.otbm')),
            otbmPort.sendPort));

    print('end');

    return Project(assets: assets, map: map);
  }

  void updateProgress(ProgressTracker tracker) {
    tracker.progress = [
      datProgress,
      sprProgress,
      xmlProgress,
      otbProgress,
      otbmProgress,
    ].average;
  }
}
