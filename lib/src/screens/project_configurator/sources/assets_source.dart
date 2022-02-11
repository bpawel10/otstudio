import 'package:otstudio/src/models/assets.dart';
import 'package:otstudio/src/models/items.dart';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:otstudio/src/screens/project_configurator/sources/source.dart';

class AssetsSource<T extends Source<Items>> extends Source<Assets> {
  final T itemsSource;

  AssetsSource({required this.itemsSource});

  @override
  Future<Assets> load(ProgressTracker tracker) async {
    Items items = await itemsSource.load(tracker);
    return Assets(items: items);
  }
}
