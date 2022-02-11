import 'package:otstudio/src/models/items.dart';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/screens/project_configurator/sources/source.dart';

class OtbXmlSprDatItemsSource extends Source<Items> {
  String? datPath;
  String? sprPath;
  String? xmlPath;
  String? otbPath;

  OtbXmlSprDatItemsSource(
      {this.datPath, this.sprPath, this.xmlPath, this.otbPath});

  Future<Items> load(ProgressTracker tracker) {
    throw UnimplementedError();
  }
}
