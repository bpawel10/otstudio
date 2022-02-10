import 'package:file_picker/file_picker.dart' as fp;

class FilePicker {
  final List<String>? extensions;

  FilePicker({this.extensions});

  pickFile(Function(String) callback) async {
    fp.FilePickerResult? result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: extensions,
      withReadStream: true,
    );
    if (result != null) {
      callback(result.files.single.path!);
    }
  }
}
