import 'package:flutter/material.dart';
import 'package:otstudio/src/init/file_picker.dart';
import 'package:otstudio/src/editor/editor.dart';

class Init extends StatefulWidget {
  @override
  _InitState createState() => _InitState();
}

class _InitState extends State<Init> {
  String itemsFilePath;
  String sprFilePath;
  String datFilePath;

  bool canCreateMap() =>
      itemsFilePath != null && sprFilePath != null && datFilePath != null;

  void createNewMap(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => Editor(
                itemsFilePath: this.itemsFilePath,
                sprFilePath: this.sprFilePath,
                datFilePath: this.datFilePath)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Create new map'),
              Visibility(
                  visible: itemsFilePath != null,
                  child: Text(itemsFilePath ?? ''),
                  replacement: FilePicker(
                    label: 'Select items file',
                    extensions: ['toml'],
                    onPickFile: (path) {
                      setState(() {
                        itemsFilePath = path;
                      });
                    },
                  )),
              Visibility(
                  visible: sprFilePath != null,
                  child: Text(sprFilePath ?? ''),
                  replacement: FilePicker(
                    label: 'Select SPR file',
                    extensions: ['spr'],
                    onPickFile: (path) {
                      setState(() {
                        sprFilePath = path;
                      });
                    },
                  )),
              Visibility(
                  visible: datFilePath != null,
                  child: Text(datFilePath ?? ''),
                  replacement: FilePicker(
                    label: 'Select DAT file',
                    extensions: ['dat'],
                    onPickFile: (path) {
                      setState(() {
                        datFilePath = path;
                      });
                    },
                  )),
              TextButton(
                  onPressed:
                      canCreateMap() ? () => createNewMap(context) : null,
                  child: Text('Create')),
            ],
          ),
        ),
      );
}
