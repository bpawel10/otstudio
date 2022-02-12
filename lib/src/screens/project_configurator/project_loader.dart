import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:otstudio/src/models/items.dart';
import 'package:otstudio/src/models/atlas.dart';
import 'package:otstudio/src/screens/editor/editor.dart';
import 'package:otstudio/src/screens/project_configurator/sources/source.dart';
import 'package:otstudio/src/models/project.dart';
import 'package:otstudio/src/screens/loader.dart';
import 'package:otstudio/src/screens/welcome/welcome_scaffold.dart';
import 'package:otstudio/src/models/texture.dart' as modelTexture;
import 'package:otstudio/src/models/assets.dart';
import 'package:otstudio/src/models/item.dart';

class ProjectLoader extends StatelessWidget {
  final Source<Project> projectSource;

  ProjectLoader({required this.projectSource});

  @override
  Widget build(BuildContext context) => WelcomeScaffold(
      child: Loader<void, Project>(
          label: 'Loading project',
          future: projectSource.load,
          callback: (Project project) async {
            Map<int, Item> items = Map();
            await Future.forEach(project.assets.items.items.values,
                (Item item) async {
              List<modelTexture.Texture> texturesWithImage = [];
              await Future.forEach(item.textures,
                  (modelTexture.Texture texture) async {
                ui.Image textureImage = await getTextureImage(texture);
                texturesWithImage.add(modelTexture.Texture(
                    width: texture.width,
                    height: texture.height,
                    bytes: texture.bytes,
                    bitmap: texture.bitmap,
                    image: textureImage));
              });
              items[item.id] = Item(
                  id: item.id,
                  name: item.name,
                  stackable: item.stackable,
                  splash: item.splash,
                  fluidContainer: item.fluidContainer,
                  textures: texturesWithImage);
            });
            Atlas atlas = await getAtlas(items);

            Project projectWithTexturesWithImages = Project(
                assets: Assets(items: Items(items: items, atlas: atlas)),
                map: project.map);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => Editor(
                          project: projectWithTexturesWithImages,
                        )));
          }));

  Future<ui.Image> getTextureImage(modelTexture.Texture texture) async {
    ui.Codec codec = await ui.instantiateImageCodec(texture.bitmap,
        targetWidth: texture.width.toInt(),
        targetHeight: texture.height.toInt());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Future<Atlas> getAtlas(Map<int, Item> items) async {
    // List<Item> items2 = items.values.take(100).toList();
    List<Item> items2 = items.values.toList();

    int atlasSize = sqrt(items2.length).ceil();

    int maxWidth = 0;
    int maxHeight = 0;

    items2.forEach((item) {
      maxWidth = max(maxWidth, item.textures[0].width.toInt());
      maxHeight = max(maxHeight, item.textures[0].height.toInt());
    });

    int atlasWidth = atlasSize * maxWidth;
    int atlasHeight = atlasSize * maxHeight;

    // items2.forEach((item) {
    //   atlasWidth += item.textures[0].width.toInt();
    //   atlasHeight = max(atlasHeight, item.textures[0].height.toInt());
    // });

    Map<int, ui.Rect> rects = Map();

    print('atlasWidth $atlasWidth atlasHeight $atlasHeight');

    img.Image atlasImg = img.Image(atlasWidth, atlasHeight);

    // int atlasPosX = 0;
    // int atlasPosY = 0;

    items2.asMap().forEach((index, item) {
      // print('atlasPos $atlasPos');

      modelTexture.Texture texture = item.textures[0];
      // ByteData? byteData = await texture.bitmap

      img.Image textureImage = img.Image.fromBytes(
          texture.width.toInt(), texture.height.toInt(), texture.bytes);

      // img.Image resized = img.copyResize(textureImage,
      //     width: textureImage.width,
      //     height: textureImage.height,
      //     interpolation: img.Interpolation.linear);

      int offsetX =
          (index % atlasSize) * maxWidth + (maxWidth - texture.width.toInt());
      int offsetY = (index / atlasSize).floor() * maxHeight +
          (maxHeight - texture.height.toInt());

      if (index < 50) {
        print(
            'index $index itemId ${item.id} offsetX $offsetX offsetY $offsetY atlasSize $atlasSize');
      }

      img.copyInto(
        atlasImg,
        textureImage,
        // Bitmap.fromHeadful(texture.width, texture.height, texture.bitmap)
        //     .content),
        dstX: offsetX,
        dstY: offsetY,
      );
      rects[item.id] = Offset(offsetX.toDouble(), offsetY.toDouble()) &
          Size(texture.width.toDouble(), texture.height.toDouble());
    });

    print('atlasWidth2 $atlasWidth atlasHeight2 $atlasHeight');

    print(
        'atlasImg.width ${atlasImg.width} atlasImg.height ${atlasImg.height}');

    // Bitmap atlasBitmap =
    //     Bitmap.fromHeadless(atlasWidth, atlasHeight, atlasImg.getBytes());

    // print(
    //     'atlasBitmap $atlasBitmap width ${atlasBitmap.width} height ${atlasBitmap.height}');

    ui.Codec codec = await ui.instantiateImageCodec(
        Uint8List.fromList(img.encodePng(atlasImg)),
        targetWidth: atlasWidth,
        targetHeight: atlasHeight);

    print('frame count ${codec.frameCount}');
    print('repetition count ${codec.repetitionCount}');

    ui.FrameInfo frameInfo = await codec.getNextFrame();
    ui.Image atlasUiImage = frameInfo.image;

    // ui.Image atlasUiImage = await ItemsLoader.getUiImage(
    //     atlasBitmap.buildHeaded(),
    //     width: atlasWidth,
    //     height: atlasHeight);

    print(
        'atlasUiImage $atlasUiImage width ${atlasUiImage.width} height ${atlasUiImage.height}');

    ByteData? data =
        await atlasUiImage.toByteData(format: ui.ImageByteFormat.png);

    // if (data != null) {
    //   await File('/Users/bpawel10/dev/tibia/otstudio/atlas.png').writeAsBytes(
    //       data.buffer.asUint8List()); // data.buffer.asUint8List());
    // }

    Atlas atlas = Atlas(atlas: atlasUiImage, rects: rects);

    // print(
    //     'atlasUiImage width ${atlasUiImage.width} height ${atlasUiImage.height} bytes ${atlas.getBytes()}');

    return atlas;
  }
}
