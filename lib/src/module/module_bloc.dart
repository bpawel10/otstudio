import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GridWidgetEvent {}

abstract class GridWidgetState {}

abstract class GridWidgetBloc extends Bloc<GridWidgetEvent, GridWidgetState> {
  GridWidgetBloc(GridWidgetState initialState) : super(initialState);
}
