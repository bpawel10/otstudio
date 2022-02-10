import 'dart:io';

import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otstudio/src/screens/welcome/welcome_scaffold.dart';

class ProjectPicker extends StatefulWidget {
  ProjectPicker();

  @override
  _State createState() => _State();
}

class _State extends State<ProjectPicker> {
  bool dragging = false;
  String? dragAndDropErrorMessage;

  showDragAndDropErrorMessage(String message) {
    setState(() => dragAndDropErrorMessage = message);
    Future future = Future.delayed(Duration(seconds: 2),
        () => setState(() => dragAndDropErrorMessage = null));
  }

  @override
  Widget build(BuildContext context) => WelcomeScaffold(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: TextButton(
                  child: FaIcon(
                    FontAwesomeIcons.arrowLeft,
                    size: 16,
                  ),
                  onPressed: () => Navigator.pop(context),
                  style: ButtonStyle(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                      minimumSize: MaterialStateProperty.all(Size.zero),
                      padding: MaterialStateProperty.all(EdgeInsets.zero)))),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child: DropTarget(
                      onDragEntered: (DropEventDetails details) =>
                          setState(() => dragging = true),
                      onDragExited: (DropEventDetails details) =>
                          setState(() => dragging = false),
                      onDragDone: (DropDoneDetails details) async {
                        if (details.files.length != 1) {
                          return showDragAndDropErrorMessage(
                              'Too many elements');
                        }
                        XFile file = details.files[0];
                        bool projectDirectoryExists =
                            await Directory(file.path).exists();
                        if (!projectDirectoryExists) {
                          return showDragAndDropErrorMessage('Not a directory');
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: dragAndDropErrorMessage != null
                              ? Border.all(width: 3, color: Colors.red.shade500)
                              : dragging
                                  ? Border.all(
                                      width: 3, color: Colors.green.shade500)
                                  : null,
                        ),
                        child: dragAndDropErrorMessage != null
                            ? Center(
                                child: Text(dragAndDropErrorMessage!,
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.red.shade500)))
                            : dragging
                                ? Center(
                                    child: Text('Drop here',
                                        style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.green.shade500)))
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        FaIcon(FontAwesomeIcons.folderPlus,
                                            color: Colors.grey.shade500),
                                        SizedBox(height: 4),
                                        Text('Drag and drop project directory',
                                            style: TextStyle(
                                                fontSize: 24,
                                                color: Colors.grey.shade500)),
                                        SizedBox(height: 10),
                                        Text(
                                          'or',
                                          style: TextStyle(
                                              color: Colors.grey.shade500),
                                        ),
                                        SizedBox(height: 8),
                                        ElevatedButton(
                                          child: Text('Browse'),
                                          onPressed: () {},
                                        ),
                                        if (dragAndDropErrorMessage != null)
                                          Text(
                                            dragAndDropErrorMessage!,
                                            style: TextStyle(color: Colors.red),
                                          ),
                                      ]),
                      ))),
              SizedBox(height: 20),
              Center(
                  child: Column(children: [
                Text('or import all necessary files manually',
                    style: TextStyle(color: Colors.grey.shade500)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(child: Text('Skyless'), onPressed: () {}),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(child: Text('TFS'), onPressed: () {}),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        child: Text('Cipsoft 7.7'), onPressed: () {}),
                  ],
                ),
              ])),
            ],
          )),
        ],
      ));
}
