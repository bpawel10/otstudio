import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/bloc/project_loader_bloc.dart';
import 'package:otstudio/src/sources/assets_source.dart';
import 'package:otstudio/src/sources/otb_xml_spr_dat_items_source.dart';
import 'package:otstudio/src/sources/otbm_map_source.dart';
import 'package:otstudio/src/sources/project_source.dart';
import 'package:otstudio/src/utils/file_picker.dart';
import 'package:otstudio/src/widgets/file_field.dart';

class OtbmProjectConfigurator extends StatelessWidget {
  final ProjectSource<AssetsSource<OtbXmlSprDatItemsSource>, OtbmMapSource>
      initialSource;

  OtbmProjectConfigurator({required this.initialSource});

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (BuildContext context) =>
          ProjectLoaderBloc(ProjectLoaderState(source: initialSource)),
      child: Scaffold(body: Container(child:
          BlocBuilder<ProjectLoaderBloc, ProjectLoaderState>(
              builder: (BuildContext context, ProjectLoaderState state) {
        ProjectLoaderBloc bloc = context.read<ProjectLoaderBloc>();
        return Column(children: [
          FileField(
              label: 'Select items.dat',
              filePicker: FilePicker(extensions: ['dat']),
              callback: (String datPath) =>
                  bloc.add(ProjectLoaderFilePickedEvent(datPath))),
        ]);
      }))));
}
