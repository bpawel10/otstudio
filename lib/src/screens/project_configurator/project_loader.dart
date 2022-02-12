import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:otstudio/src/models/items.dart';
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
            Project projectWithTexturesWithImages = Project(
                assets: Assets(items: Items(items: items)), map: project.map);
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
}
