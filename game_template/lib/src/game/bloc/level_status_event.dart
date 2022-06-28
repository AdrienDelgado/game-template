part of 'level_status_bloc.dart';

@immutable
abstract class LevelStatusEvent {}

class StartLoadingIngredientsEvent extends LevelStatusEvent {}

class MarkLevelReadyEvent extends LevelStatusEvent {}

class StartGameEvent extends LevelStatusEvent {}