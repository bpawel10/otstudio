import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otstudio/src/sources/assets_source.dart';
import 'package:otstudio/src/sources/otb_xml_spr_dat_items_source.dart';
import 'package:otstudio/src/sources/otbm_map_source.dart';
import 'package:otstudio/src/sources/project_source.dart';
import 'package:otstudio/src/utils/file_picker.dart';
import 'project_configurator.dart';

class Buttons extends StatelessWidget {
  Buttons();

  void createNewProject(BuildContext context) {
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (_) => ProjectConfigurator()));
  }

  void openProject(BuildContext context) {}

  void importOtbm(BuildContext context, String otbmPath) {
    ProjectSource source = ProjectSource(
        assetsSource: AssetsSource(itemsSource: OtbXmlSprDatItemsSource()),
        mapSource: OtbmMapSource(otbmPath: otbmPath));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                ProjectConfigurator(initialSource: source)));
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
          SizedBox(height: 10),
          ElevatedButton.icon(
              icon: FaIcon(FontAwesomeIcons.fileImport, size: 16),
              label: Text('Import OTBM'),
              onPressed: () => FilePicker(extensions: ['otbm'])
                  .pickFile((path) => importOtbm(context, path))),
        ],
      );
}
