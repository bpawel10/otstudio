import 'package:flutter/material.dart';
import 'package:otstudio/src/init/file_picker.dart';
import 'package:otstudio/src/editor/editor.dart';
import 'package:otstudio/src/widgets/input.dart';

class Init extends StatefulWidget {
  @override
  InitState createState() => InitState();
}

class InitState extends State<Init> {
  String? otbmFilePath;
  String? itemsFilePath;
  String? sprFilePath;
  String? datFilePath;
  int width = 256;
  int height = 256;

  bool canCreateMap() =>
      itemsFilePath != null &&
      sprFilePath != null &&
      datFilePath != null &&
      width > 0 &&
      height > 0;

  void createNewMap(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => Editor(
                otbmFilePath: this.otbmFilePath,
                itemsFilePath: this.itemsFilePath ?? '',
                sprFilePath: this.sprFilePath ?? '',
                datFilePath: this.datFilePath ?? '',
                width: this.width,
                height: this.height)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'OTStudio',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              Text(
                'Create new map',
                style: TextStyle(fontSize: 16),
              ),
              Visibility(
                  visible: otbmFilePath != null,
                  child: Text(otbmFilePath ?? ''),
                  replacement: FilePicker(
                    label: 'Select map',
                    extensions: ['otbm'],
                    onPickFile: (path) {
                      setState(() {
                        otbmFilePath = path;
                      });
                    },
                  )),
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
              SizedBox(height: 10),
              SizedBox(
                  width: 100,
                  // width: 200,
                  child: Input(
                      label: 'Width',
                      value: this.width.toString(),
                      onChanged: (width) =>
                          setState(() => this.width = int.parse(width)))),

              SizedBox(height: 4),
              SizedBox(
                  width: 100,
                  // width: 200,
                  child: Input(
                      label: 'Height',
                      value: this.height.toString(),
                      onChanged: (height) =>
                          setState(() => this.height = int.parse(height)))),

              // TextFormField(
              //   decoration: InputDecoration(label: Text('Height')),
              //   keyboardType: TextInputType.number,
              //   // inputFormatters: <TextInputFormatter>[
              //   //   WhitelistingTextInputFormatter.digitsOnly
              //   // ],
              //   initialValue: this.height.toString(),
              //   onChanged:
              // )),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed:
                      canCreateMap() ? () => createNewMap(context) : null,
                  child: Text('Create')),
            ],
          ),
        ),
      );
}
