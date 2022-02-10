import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/sources/assets_source.dart';
import 'package:otstudio/src/sources/otb_xml_spr_dat_items_source.dart';
import 'package:otstudio/src/sources/otbm_source.dart';
import 'package:otstudio/src/sources/project_source.dart';
import 'package:otstudio/src/sources/source.dart';
import 'package:otstudio/src/utils/file_picker.dart';
import 'package:otstudio/src/widgets/file_field.dart';
import 'package:otstudio/src/models/project.dart';

class OtbmProjectConfigurator extends StatefulWidget {
  final String otbmPath;

  OtbmProjectConfigurator({required this.otbmPath});

  @override
  _State createState() => _State(ProjectSource(
      assetsSource: AssetsSource(itemsSource: OtbXmlSprDatItemsSource()),
      mapSource: OtbmSource(otbmPath: otbmPath)));
}

class _State extends State<OtbmProjectConfigurator> {
  ProjectSource<AssetsSource<OtbXmlSprDatItemsSource>, OtbmSource> source;

  _State(this.source);

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Container(
              child: Column(children: [
        FileField(
            label: 'Select DAT file',
            filePicker: FilePicker(extensions: ['dat']),
            callback: (String path) =>
                setState(() => source.assetsSource.itemsSource.datPath = path)),
        FileField(
            label: 'Select SPR file',
            filePicker: FilePicker(extensions: ['spr']),
            callback: (String path) =>
                setState(() => source.assetsSource.itemsSource.sprPath = path)),
        FileField(
            label: 'Select XML file',
            filePicker: FilePicker(extensions: ['xml']),
            callback: (String path) =>
                setState(() => source.assetsSource.itemsSource.xmlPath = path)),
        FileField(
            label: 'Select OTB file',
            filePicker: FilePicker(extensions: ['otb']),
            callback: (String path) =>
                setState(() => source.assetsSource.itemsSource.otbPath = path)),
      ])));
}
