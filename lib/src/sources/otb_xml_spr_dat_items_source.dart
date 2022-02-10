import 'package:otstudio/src/sources/source.dart';
import 'package:otstudio/src/models/items.dart';

class OtbXmlSprDatItemsSource extends Source<Items> {
  String? datPath;
  String? sprPath;
  String? xmlPath;
  String? otbPath;

  OtbXmlSprDatItemsSource(
      {this.datPath, this.sprPath, this.xmlPath, this.otbPath});

  Future<Items> load() {
    throw UnimplementedError();
  }
}
