import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otstudio/src/utils/file_picker.dart';

class FileField extends StatelessWidget {
  final String? value;
  final String label;
  final FilePicker filePicker;
  final Function(String) callback;

  const FileField({
    this.value,
    required this.label,
    required this.filePicker,
    required this.callback,
  });

  Widget build(BuildContext context) => Row(children: [
        // TextField(),
        ElevatedButton.icon(
          icon: FaIcon(FontAwesomeIcons.upload, size: 16),
          label: Text(this.label),
          onPressed: () => filePicker.pickFile((path) => callback(path)),
        ),
      ]);
}
