part of 'level_status_bloc.dart';

@immutable
abstract class LevelStatusState {}

class LevelStatusInitial extends LevelStatusState {}

class InitialLoadingState extends LevelStatusState {}