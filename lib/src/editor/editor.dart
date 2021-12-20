import 'dart:collection';
import 'dart:isolate';
import 'package:bitmap/bitmap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/serializers/disk_serializer.dart';
import 'package:otstudio/src/serializers/map/otbm_serializer.dart';
import '../loaders/items_loader.dart';
import '../models/item.dart';
import './map.dart';
import '../widgets/resizable_column.dart';
import '../models/position.dart';
import '../models/tile.dart';
import '../models/area_map.dart';
import 'dart:ui' as ui;
import '../models/texture.dart' as t;
import '../models/atlas.dart';

const TILE_SIZE = 32;

class ComputeLoadMapPayload {
  ProgressTracker<DiskSerializerDeserializePayload> tracker;
  List<Item> items;

  ComputeLoadMapPayload(this.tracker, this.items);
}

Future<AreaMap> computeLoadMap(ComputeLoadMapPayload payload) async {
  OtbmSerializer serializer = OtbmSerializer(payload.items);
  return serializer.deserialize(payload.tracker);
}

class Editor extends StatefulWidget {
  final String? otbmFilePath;
  // final String itemsFilePath;
  final String otbFilePath;
  final String xmlFilePath;
  final String sprFilePath;
  final String datFilePath;
  final int width;
  final int height;

  Editor(
      {this.otbmFilePath,
      // required this.itemsFilePath,
      required this.otbFilePath,
      required this.xmlFilePath,
      required this.sprFilePath,
      required this.datFilePath,
      required this.width,
      required this.height});

  @override
  EditorState createState() => EditorState();
}

class EditorState extends State<Editor> {
  late AreaMap map;
  late List<Item> items = [];
  late Atlas atlas;
  int? selectedItemIndex;
  // late Future<List<Item>> itemsLoaderFuture;
  late ItemsLoaderProgress itemsProgress = ItemsLoaderProgress();

  //late Future<AreaMap>? otbmSerializerFuture;
  late double mapProgress = 0;

  late Future<EditorData> loadDataFuture;

  @override
  initState() {
    super.initState();
    loadDataFuture = loadData();
    // itemsLoaderFuture = loadItems();
    // if (widget.otbmFilePath != null) {
    //   otbmSerializerFuture = loadMap();
    // }
  }

  Future<EditorData> loadData() async {
    List<Item> items = await loadItems();
    Atlas atlas = await ItemsLoader.getAtlas(items);
    AreaMap map = await loadMap();
    return EditorData(items: items, atlas: atlas, map: map);
  }

  Future<List<Item>> loadItems() async {
    ReceivePort receivePort = ReceivePort();
    receivePort
        .listen((progress) => setState(() => this.itemsProgress = progress));
    ItemsLoaderPayload payload = ItemsLoaderPayload(
      // itemsFilePath: widget.itemsFilePath,
      otbFilePath: widget.otbFilePath,
      xmlFilePath: widget.xmlFilePath,
      sprFilePath: widget.sprFilePath,
      datFilePath: widget.datFilePath,
      sendPort: receivePort.sendPort,
    );
    List<Item> items = await compute(ItemsLoader.load, payload);
    int i = 0;
    await Future.forEach(items, (Item item) async {
      await Future.forEach(item.textures, (t.Texture texture) async {
        ui.Image uiImage = await ItemsLoader.getUiImage(texture.bitmap,
            width: texture.width, height: texture.height);
        texture.image = uiImage;
      });

      // item.image = ItemsLoader.getImage(item.bitmap);
      // ui.Image uiImage = await ItemsLoader.getUiImage(item.bitmap);
      // item.uiImage = uiImage;

      // List<Image> images = List.empty(growable: true);
      // item.sprites.forEach((bitmap) async {
      //   Image spriteImage = ItemsLoader.getImage(bitmap);
      //   images.add(spriteImage);
      // });
      // item.images = images;

      setState(
          () => itemsProgress.itemsProgress = (i + 1) / items.length / 2 + 0.5);
      i++;
    });

    return items;
  }

  Future<AreaMap> loadMap() async {
    print('loadMap');
    if (widget.otbmFilePath == null) {
      return AreaMap.empty(width: widget.width, height: widget.height);
    }

    ReceivePort receivePort = ReceivePort();
    receivePort
        .listen((progress) => setState(() => this.mapProgress = progress));
    print('compute deserialize');

    AreaMap map = await compute(
        computeLoadMap,
        ComputeLoadMapPayload(
            ProgressTracker(
                DiskSerializerDeserializePayload(widget.otbmFilePath!),
                receivePort.sendPort),
            items));
    print('loaded map $map width ${map.width} height ${map.height}');
    return map;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: FutureBuilder<EditorData>(
          // List<Item>>(
          future: loadDataFuture, // otbmSerializerFuture, // itemsLoaderFuture,
          builder: (context, snapshot) {
            // print('snapshot');
            if (snapshot.hasError) {
              print('error ${snapshot.error}');
            }
            if (snapshot.hasData) {
              items = snapshot.data?.items as List<Item>;
              atlas = snapshot.data?.atlas as Atlas;
              map = snapshot.data?.map as AreaMap;

              // items = snapshot.data!;
              return Container(
                  child: Row(children: [
                ResizableColumn(
                    initialWidth: 200,
                    minWidth: 50,
                    child: Scrollbar(
                        isAlwaysShown: true,
                        child: ListView.builder(
                            physics: ClampingScrollPhysics(),
                            cacheExtent: 10000,
                            // (items.length * (TILE_SIZE + 4)).toDouble(),
                            itemCount: items.length,
                            itemBuilder: (context, index) => GestureDetector(
                                onTap: () =>
                                    setState(() => selectedItemIndex = index),
                                child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Container(
                                        decoration: index == selectedItemIndex
                                            ? BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor)
                                            : BoxDecoration(),
                                        child: Padding(
                                            padding: EdgeInsets.all(2),
                                            child: Row(children: [
                                              // SizedBox(
                                              //     width: TILE_SIZE.toDouble(),
                                              //     height: TILE_SIZE.toDouble(),
                                              //     // TODO: use container with rounded corners instead
                                              //     child: ClipRRect(
                                              //         borderRadius:
                                              //             BorderRadius.circular(
                                              //                 3),
                                              //         child: Image.memory(
                                              //             items[index]
                                              //                 .texture
                                              //                 .bitmap))),
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 2),
                                                  child: Row(
                                                      children: items[index]
                                                          .textures
                                                          .take(1)
                                                          .map((texture) =>
                                                              // SizedBox(
                                                              //     width: TILE_SIZE
                                                              //         .toDouble(),
                                                              //     height: TILE_SIZE
                                                              //         .toDouble(),
                                                              //     // TODO: use container with rounded corners instead
                                                              //     child:
                                                              SizedBox.square(
                                                                  dimension:
                                                                      SPRITE_SIZE
                                                                          .toDouble(),
                                                                  child: ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              3),
                                                                      child: Image.memory(
                                                                          texture
                                                                              .bitmap))))
                                                          .toList())),
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 5),
                                                  child: Text(
                                                      '${items[index].id.toString()}'))
                                            ])))))))),
                // Text('spriteId:' + items[index].spriteId.toString())
                // child: ListView(
                //     children: items
                //         .asMap()
                //         .map((index, item) => MapEntry(
                //             index,
                //             GestureDetector(
                //                 onTap: () => setState(
                //                     () => selectedItemIndex = index),
                //                 child: MouseRegion(
                //                     cursor: SystemMouseCursors.click,
                //                     child: Container(
                //                         decoration:
                //                             index == selectedItemIndex
                //                                 ? BoxDecoration(
                //                                     color: Theme.of(context)
                //                                         .primaryColor)
                //                                 : BoxDecoration(),
                //                         child: Padding(
                //                             padding: EdgeInsets.all(2),
                //                             child: Row(children: [
                //                               SizedBox(
                //                                   width:
                //                                       TILE_SIZE.toDouble(),
                //                                   height:
                //                                       TILE_SIZE.toDouble(),
                //                                   child: ClipRRect(
                //                                       borderRadius:
                //                                           BorderRadius
                //                                               .circular(3),
                //                                       child: items[index]
                //                                           .image)),
                //                               Padding(
                //                                   padding: EdgeInsets.only(
                //                                       left: 5),
                //                                   child: Text(items[index]
                //                                       .id
                //                                       .toString())),
                //                             ])))))))
                //         .values
                //         .toList())),
                Expanded(
                    child: Map(
                  map: map,
                  items: items,
                  atlas: atlas,
                  width: map.width, // widget.width,
                  height: map.height, // widget.height,
                  selectedItem: selectedItemIndex != null
                      ? items[selectedItemIndex!]
                      : null,
                )),
              ]));
            } else {
              return Container(
                  child: Center(
                      child: SizedBox(
                          width: 120,
                          height: 23,
                          child: Visibility(
                              visible: itemsProgress.spritesProgress < 1,
                              child: Column(children: [
                                // TODO: use container with rounded corners instead
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                        value: itemsProgress.spritesProgress)),
                                Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Text('Loading sprites')),
                              ]),
                              replacement: Visibility(
                                visible: itemsProgress.itemsProgress < 1,
                                child: Column(children: [
                                  // TODO: use container with rounded corners instead
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                          value: itemsProgress.itemsProgress)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Text('Loading items')),
                                ]),
                                replacement: Column(children: [
                                  // TODO: use container with rounded corners instead
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                          value: mapProgress)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Text('Loading map')),
                                ]),
                              ))))

                  // width: 60,
                  // height: 60,
                  );
            }
          }));
}

class EditorData {
  List<Item> items;
  Atlas atlas;
  AreaMap map;

  EditorData({required this.items, required this.atlas, required this.map});
}
