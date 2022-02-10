import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:otstudio/src/widgets/file_field.dart';
import 'package:otstudio/src/screens/editor/editor.dart';
import 'package:otstudio/src/widgets/input.dart';
import 'header.dart';
import 'buttons.dart';
import 'recent_projects.dart';

class Welcome extends StatelessWidget {
  String? otbmFilePath;
  // String? itemsFilePath;
  String? otbFilePath;
  String? xmlFilePath;
  String? sprFilePath;
  String? datFilePath;
  String? atlasFilePath;
  int width = 256;
  int height = 256;

  bool canCreateMap() =>
      // itemsFilePath != null &&
      otbFilePath != null &&
      // xmlFilePath != null &&
      sprFilePath != null &&
      datFilePath != null &&
      atlasFilePath != null &&
      width > 0 &&
      height > 0;

  // void createNewMap(BuildContext context) {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (_) => Editor(
  //               // otbmFilePath: this.otbmFilePath,
  //               // // itemsFilePath: this.itemsFilePath ?? '',
  //               // otbFilePath: this.otbFilePath ?? '',
  //               // xmlFilePath: this.xmlFilePath ?? '',
  //               // sprFilePath: this.sprFilePath ?? '',
  //               // datFilePath: this.datFilePath ?? '',
  //               // width: this.width,
  //               // height: this.height,
  //               )));
  // }

  @override
  Widget build(BuildContext context) => Column(children: [
        WindowTitleBarBox(
          child: MoveWindow(),
        ),
        Expanded(
            child: Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Row(children: [
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Header(),
                      SizedBox(
                        height: 20,
                      ),
                      Buttons(),
                    ],
                  )),
                  Expanded(child: RecentProjects()),
                ]))),
      ]);
}

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Text(
//                 'OTStudio',
//                 style: TextStyle(fontSize: 24),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Create new map',
//                 style: TextStyle(fontSize: 16),
//               ),
//               Visibility(
//                   visible: otbmFilePath != null,
//                   child: Text(otbmFilePath ?? ''),
//                   replacement: FilePicker(
//                     label: 'Select map',
//                     extensions: ['otbm'],
//                     onPickFile: (path) {
//                       setState(() {
//                         otbmFilePath = path;
//                       });
//                     },
//                   )),
//               // Visibility(
//               //     visible: itemsFilePath != null,
//               //     child: Text(itemsFilePath ?? ''),
//               //     replacement: FilePicker(
//               //       label: 'Select items file',
//               //       extensions: ['toml'],
//               //       onPickFile: (path) {
//               //         setState(() {
//               //           itemsFilePath = path;
//               //         });
//               //       },
//               //     )),
//               Visibility(
//                   visible: otbFilePath != null,
//                   child: Text(otbFilePath ?? ''),
//                   replacement: FilePicker(
//                     label: 'Select items.otb file',
//                     extensions: ['otb'],
//                     onPickFile: (path) {
//                       setState(() {
//                         otbFilePath = path;
//                       });
//                     },
//                   )),
//               // Visibility(
//               //     visible: xmlFilePath != null,
//               //     child: Text(xmlFilePath ?? ''),
//               //     replacement: FilePicker(
//               //       label: 'Select items.xml file',
//               //       extensions: ['xml'],
//               //       onPickFile: (path) {
//               //         setState(() {
//               //           xmlFilePath = path;
//               //         });
//               //       },
//               //     )),
//               Visibility(
//                   visible: sprFilePath != null,
//                   child: Text(sprFilePath ?? ''),
//                   replacement: FilePicker(
//                     label: 'Select SPR file',
//                     extensions: ['spr'],
//                     onPickFile: (path) {
//                       setState(() {
//                         sprFilePath = path;
//                       });
//                     },
//                   )),
//               Visibility(
//                   visible: datFilePath != null,
//                   child: Text(datFilePath ?? ''),
//                   replacement: FilePicker(
//                     label: 'Select DAT file',
//                     extensions: ['dat'],
//                     onPickFile: (path) {
//                       setState(() {
//                         datFilePath = path;
//                       });
//                     },
//                   )),
//               Visibility(
//                   visible: atlasFilePath != null,
//                   child: Text(atlasFilePath ?? ''),
//                   replacement: FilePicker(
//                     label: 'Select ATLAS file',
//                     extensions: ['png'],
//                     onPickFile: (path) {
//                       setState(() {
//                         atlasFilePath = path;
//                       });
//                     },
//                   )),
//               SizedBox(height: 10),
//               SizedBox(
//                   width: 100,
//                   // width: 200,
//                   child: Input(
//                       label: 'Width',
//                       value: this.width.toString(),
//                       onChanged: (width) =>
//                           setState(() => this.width = int.parse(width)))),

//               SizedBox(height: 4),
//               SizedBox(
//                   width: 100,
//                   // width: 200,
//                   child: Input(
//                       label: 'Height',
//                       value: this.height.toString(),
//                       onChanged: (height) =>
//                           setState(() => this.height = int.parse(height)))),

//               // TextFormField(
//               //   decoration: InputDecoration(label: Text('Height')),
//               //   keyboardType: TextInputType.number,
//               //   // inputFormatters: <TextInputFormatter>[
//               //   //   WhitelistingTextInputFormatter.digitsOnly
//               //   // ],
//               //   initialValue: this.height.toString(),
//               //   onChanged:
//               // )),
//               SizedBox(height: 20),
//               ElevatedButton(
//                   onPressed:
//                       canCreateMap() ? () => createNewMap(context) : null,
//                   child: Text('Create')),
//             ],
//           ),
//         ),
//       );
// }
