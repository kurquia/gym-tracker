// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workouts_dao.dart';

// ignore_for_file: type=lint
mixin _$WorkoutsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $RoutinesTable get routines => attachedDatabase.routines;
  $SessionsTable get sessions => attachedDatabase.sessions;
  $SessionExercisesTable get sessionExercises =>
      attachedDatabase.sessionExercises;
  $SetsTable get sets => attachedDatabase.sets;
  $SetupFieldsTable get setupFields => attachedDatabase.setupFields;
  $SetupValuesTable get setupValues => attachedDatabase.setupValues;
  WorkoutsDaoManager get managers => WorkoutsDaoManager(this);
}

class WorkoutsDaoManager {
  final _$WorkoutsDaoMixin _db;
  WorkoutsDaoManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db.attachedDatabase, _db.routines);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db.attachedDatabase, _db.sessions);
  $$SessionExercisesTableTableManager get sessionExercises =>
      $$SessionExercisesTableTableManager(
        _db.attachedDatabase,
        _db.sessionExercises,
      );
  $$SetsTableTableManager get sets =>
      $$SetsTableTableManager(_db.attachedDatabase, _db.sets);
  $$SetupFieldsTableTableManager get setupFields =>
      $$SetupFieldsTableTableManager(_db.attachedDatabase, _db.setupFields);
  $$SetupValuesTableTableManager get setupValues =>
      $$SetupValuesTableTableManager(_db.attachedDatabase, _db.setupValues);
}
