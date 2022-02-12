import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/bloc/project_bloc.dart';
import 'package:otstudio/src/models/item.dart';
import 'package:otstudio/src/models/sprite.dart';
import 'package:otstudio/src/widgets/resizable_column.dart';

class MapItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BlocBuilder<ProjectBloc, ProjectState>(
      builder: (BuildContext context, ProjectState state) => ResizableColumn(
          initialWidth: 200,
          minWidth: 50,
          child: Column(children: [
            SizedBox(height: 26, child: MoveWindow()),
            Expanded(
                child: Scrollbar(
                    isAlwaysShown: true,
                    child: ListView.builder(
                        physics: ClampingScrollPhysics(),
                        cacheExtent: 10000,
                        // (items.length * (TILE_SIZE + 4)).toDouble(),
                        itemCount: state.project.assets.items.length,
                        itemBuilder: (context, index) {
                          Item item =
                              state.project.assets.items.getByIndex(index);
                          return MapItem(
                            item: item,
                            selected:
                                item.id == state.project.map.selectedItemId,
                          );
                        }))),
          ])));
}

class MapItem extends StatelessWidget {
  final Item item;
  final bool selected;

  MapItem({required this.item, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => context
            .read<ProjectBloc>()
            .add(SelectedItemProjectEvent(id: item.id)),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
                decoration: selected
                    ? BoxDecoration(color: Theme.of(context).primaryColor)
                    : null,
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
                          padding: EdgeInsets.only(left: 2),
                          child: Row(
                              children: item.textures
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
                                          dimension: Sprite.SIZE.toDouble(),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              child: Image.memory(
                                                  texture.bitmap))))
                                  .toList())),
                      Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(item.name)),
                    ])))));
  }
}
