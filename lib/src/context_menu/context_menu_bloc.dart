import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'context_menu.dart';

abstract class ContextMenuEvent {}

class ContextMenuOpened extends ContextMenuEvent {
  final Offset offset;
  final ContextMenu menu;

  ContextMenuOpened({required this.offset, required this.menu});
}

class ContextMenuClosed extends ContextMenuEvent {}

abstract class ContextMenuState {}

class ContextMenuOpenedState extends ContextMenuState {
  Offset offset;
  ContextMenu menu;

  ContextMenuOpenedState({required this.offset, required this.menu});
}

class ContextMenuClosedState extends ContextMenuState {}

class ContextMenuBloc extends Bloc<ContextMenuEvent, ContextMenuState> {
  ContextMenuBloc([ContextMenuState? initialState])
      : super(initialState ?? ContextMenuClosedState()) {
    on<ContextMenuOpened>((event, emit) =>
        emit(ContextMenuOpenedState(offset: event.offset, menu: event.menu)));
    on<ContextMenuClosed>((event, emit) => emit(ContextMenuClosedState()));
  }
}
