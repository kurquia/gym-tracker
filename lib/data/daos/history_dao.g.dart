// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_dao.dart';

// ignore_for_file: type=lint
mixin _$HistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $MusclesTable get muscles => attachedDatabase.muscles;
  $ExerciseMusclesTable get exerciseMuscles => attachedDatabase.exerciseMuscles;
  $RoutinesTable get routines => attachedDatabase.routines;
  $SessionsTable get sessions => attachedDatabase.sessions;
  $SessionExercisesTable get sessionExercises =>
      attachedDatabase.sessionExercises;
  $SetsTable get sets => attachedDatabase.sets;
  $SetupFieldsTable get setupFields => attachedDatabase.setupFields;
  $SetupValuesTable get setupValues => attachedDatabase.setupValues;
  HistoryDaoManager get managers => HistoryDaoManager(this);
}

class HistoryDaoManager {
  final _$HistoryDaoMixin _db;
  HistoryDaoManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$MusclesTableTableManager get muscles =>
      $$MusclesTableTableManager(_db.attachedDatabase, _db.muscles);
  $$ExerciseMusclesTableTableManager get exerciseMuscles =>
      $$ExerciseMusclesTableTableManager(
        _db.attachedDatabase,
        _db.exerciseMuscles,
      );
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
