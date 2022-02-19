import 'package:file_picker/file_picker.dart' as fp;

class FilePicker {
  final List<String>? extensions;

  FilePicker({this.extensions});

  pickFile(Function(String) callback) async {
    pick((List<String> files) {
      callback(files[0]);
    });
  }

  pickDirectory(Function(String) callback) async {
    String? path = await fp.FilePicker.platform.getDirectoryPath();
    if (path != null) {
      callback(path);
    }
  }

  pick(Function(List<String>) callback) async {
    fp.FilePickerResult? result = await fp.FilePicker.platform.pickFiles(
      type: extensions == null ? fp.FileType.any : fp.FileType.custom,
      allowedExtensions: extensions,
      withReadStream: true,
    );
    if (result != null) {
      callback(result.files.map((fp.PlatformFile file) => file.path!).toList());
    }
  }
}
