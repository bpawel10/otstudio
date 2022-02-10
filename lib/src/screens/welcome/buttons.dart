import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otstudio/src/screens/project_configurator/otbm_project_configurator.dart';
import 'package:otstudio/src/screens/project_configurator/project_picker.dart';
import 'package:otstudio/src/utils/file_picker.dart';

class Buttons extends StatelessWidget {
  Buttons();

  void createNewProject(BuildContext context) {
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (_) => ProjectConfigurator()));
  }

  void openProject(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => ProjectPicker()));
  }

  // void importOtbm(BuildContext context, String otbmPath) {
  // }

  void openProjectConfigurator(BuildContext context, Widget configurator) {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => configurator));
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ElevatedButton.icon(
              icon: FaIcon(FontAwesomeIcons.plus, size: 16),
              label: Text('New'),
              onPressed: () => createNewProject(context)),
          SizedBox(height: 10),
          ElevatedButton.icon(
              icon: FaIcon(FontAwesomeIcons.solidFolderOpen, size: 16),
              label: Text('Open'),
              onPressed: () => openProject(context)),
          // SizedBox(height: 10),
          // ElevatedButton.icon(
          //     icon: FaIcon(FontAwesomeIcons.fileImport, size: 16),
          //     label: Text('Import OTBM'),
          //     onPressed: () => FilePicker(extensions: ['otbm']).pickFile(
          //         (path) => openProjectConfigurator(
          //             context, OtbmProjectConfigurator(otbmPath: path)))),
        ],
      );
}
