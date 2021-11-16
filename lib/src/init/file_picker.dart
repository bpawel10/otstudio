import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';

class FilePicker extends StatefulWidget {
  final String label;
  final List<String> extensions;
  final Function(String) onPickFile;

  const FilePicker({
    this.label,
    this.extensions,
    this.onPickFile,
  });

  @override
  FilePickerState createState() => FilePickerState();
}

class FilePickerState extends State<FilePicker> {
  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () async {
          fp.FilePickerResult result = await fp.FilePicker.platform.pickFiles(
              type: fp.FileType.custom,
              allowedExtensions: widget.extensions,
              withReadStream: true);
          if (result != null) {
            widget.onPickFile(result.files.single.path);
          }
        },
        child: Text(widget.label ?? ''),
      );
}
