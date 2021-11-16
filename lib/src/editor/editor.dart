import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:otstudio/src/loaders/items_loader.dart';
import 'package:otstudio/src/models/item.dart';
import 'package:otstudio/src/editor/map.dart';

class Editor extends StatefulWidget {
  final String itemsFilePath;
  final String sprFilePath;
  final String datFilePath;

  Editor({this.itemsFilePath, this.sprFilePath, this.datFilePath});

  @override
  EditorState createState() => EditorState();
}

class EditorState extends State<Editor> {
  List<Item> items;

  @override
  Widget build(BuildContext context) => Scaffold(
      body: FutureBuilder<List<Item>>(
          future: ItemsLoader.load(
              widget.itemsFilePath, widget.sprFilePath, widget.datFilePath),
          builder: (context, snapshot) {
            dev.log('aaa');
            if (snapshot.hasData) {
              items = snapshot.data;
              return Container(
                  // decoration: BoxDecoration(color: Colors.black),
                  child: Row(children: [
                SizedBox(
                  width: 200,
                  child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Row(children: [
                            Container(
                                // decoration:
                                //     BoxDecoration(color: Colors.white),
                                child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: items[index].image)),
                            Text('id:' + items[index].id.toString()),
                            Text('spriteId:' + items[index].spriteId.toString())
                          ]))),
                ),
                Map(),
              ]));
            } else {
              return Container(
                  child: Center(
                      child: SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              )));
            }
          }));
}
