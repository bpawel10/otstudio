import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppEvent {}

class AppInitEvent extends AppEvent {}

class AppState {
  final PackageInfo? packageInfo;
  final List<String>? recentProjects;

  const AppState({this.packageInfo, this.recentProjects});
}

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({AppState initialState = const AppState()}) : super(initialState) {
    on<AppInitEvent>((event, emit) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      List<String>? recentProjects =
          preferences.getStringList('recentProjects');
      emit(AppState(
          packageInfo: packageInfo,
          recentProjects: recentProjects ??
              [
                'aaa/bbb/ccc/ddd/eee/fff/ggg/hhh/jjj/kkk/lll/mmm/nnn/ooo/ppp/qqq'
              ]));
    });
  }
}
