import 'package:otstudio/src/models/assets.dart';
import 'package:otstudio/src/models/items.dart';
import 'package:otstudio/src/sources/source.dart';

class AssetsSource<T extends Source<Items>> extends Source<Assets> {
  final T itemsSource;

  AssetsSource({required this.itemsSource});

  @override
  Future<Assets> load() async {
    Items items = await itemsSource.load();
    return Assets(items: items);
  }
}
