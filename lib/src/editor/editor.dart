import 'dart:collection';
import 'dart:isolate';
import 'package:bitmap/bitmap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../loaders/items_loader.dart';
import '../models/item.dart';
import './map.dart';
import '../widgets/resizable_column.dart';
import '../models/position.dart';
import '../models/tile.dart';
import '../models/area_map.dart';
import 'dart:ui' as ui;

const TILE_SIZE = 32;

class Editor extends StatefulWidget {
  final String itemsFilePath;
  final String sprFilePath;
  final String datFilePath;
  final int width;
  final int height;

  Editor(
      {this.itemsFilePath,
      this.sprFilePath,
      this.datFilePath,
      this.width,
      this.height});

  @override
  EditorState createState() => EditorState();
}

class EditorState extends State<Editor> {
  List<Item> items;
  int selectedItemIndex;
  Future<List<Item>> itemsLoaderFuture;
  ItemsLoaderProgress progress;

  @override
  initState() {
    super.initState();
    itemsLoaderFuture = loadItems();
  }

  Future<List<Item>> loadItems() async {
    ReceivePort receivePort = ReceivePort();
    receivePort.listen((progress) => setState(() => this.progress = progress));
    ItemsLoaderPayload payload = ItemsLoaderPayload(
      itemsFilePath: widget.itemsFilePath,
      sprFilePath: widget.sprFilePath,
      datFilePath: widget.datFilePath,
      sendPort: receivePort.sendPort,
    );
    List<Item> items = await compute(ItemsLoader.load, payload);
    int i = 0;
    await Future.forEach(items, (Item item) async {
      item.image = ItemsLoader.getImage(item.bitmap);
      ui.Image uiImage = await ItemsLoader.getUiImage(item.bitmap);
      item.uiImage = uiImage;

      List<Image> images = List.empty(growable: true);
      item.sprites.forEach((bitmap) async {
        Image spriteImage = ItemsLoader.getImage(bitmap);
        images.add(spriteImage);
      });
      item.images = images;

      setState(() => progress.itemsProgress = (i + 1) / items.length / 2 + 0.5);
      i++;
    });
    return items;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: FutureBuilder<List<Item>>(
          future: itemsLoaderFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              items = snapshot.data;
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
                                              SizedBox(
                                                  width: TILE_SIZE.toDouble(),
                                                  height: TILE_SIZE.toDouble(),
                                                  // TODO: use container with rounded corners instead
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3),
                                                      child:
                                                          items[index].image)),
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 10),
                                                  child: Row(
                                                      children: items[index]
                                                          .images
                                                          .map((image) =>
                                                              SizedBox(
                                                                  width: TILE_SIZE
                                                                      .toDouble(),
                                                                  height: TILE_SIZE
                                                                      .toDouble(),
                                                                  // TODO: use container with rounded corners instead
                                                                  child: ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              3),
                                                                      child:
                                                                          image)))
                                                          .toList())),
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 5),
                                                  child: Text(
                                                      '${items[index].id.toString()} (${items[index].name})'))
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
                  width: widget.width,
                  height: widget.height,
                  selectedItem: selectedItemIndex != null
                      ? items[selectedItemIndex]
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
                            visible: progress?.spritesProgress == null ||
                                progress.spritesProgress < 1,
                            child: Column(children: [
                              // TODO: use container with rounded corners instead
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                      value: progress?.spritesProgress ?? 0)),
                              Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Text('Loading sprites')),
                            ]),
                            replacement: Column(children: [
                              // TODO: use container with rounded corners instead
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                      value: progress?.itemsProgress ?? 0)),
                              Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Text('Loading items')),
                            ]),
                          )))

                  // width: 60,
                  // height: 60,
                  );
            }
          }));
}
