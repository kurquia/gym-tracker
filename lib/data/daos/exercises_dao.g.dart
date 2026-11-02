// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercises_dao.dart';

// ignore_for_file: type=lint
mixin _$ExercisesDaoMixin on DatabaseAccessor<AppDatabase> {
  $MusclesTable get muscles => attachedDatabase.muscles;
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $ExerciseMusclesTable get exerciseMuscles => attachedDatabase.exerciseMuscles;
  $RoutinesTable get routines => attachedDatabase.routines;
  $RoutineExercisesTable get routineExercises =>
      attachedDatabase.routineExercises;
  $SessionsTable get sessions => attachedDatabase.sessions;
  $SessionExercisesTable get sessionExercises =>
      attachedDatabase.sessionExercises;
  $SetsTable get sets => attachedDatabase.sets;
  $SetupFieldsTable get setupFields => attachedDatabase.setupFields;
  $SetupValuesTable get setupValues => attachedDatabase.setupValues;
  ExercisesDaoManager get managers => ExercisesDaoManager(this);
}

class ExercisesDaoManager {
  final _$ExercisesDaoMixin _db;
  ExercisesDaoManager(this._db);
  $$MusclesTableTableManager get muscles =>
      $$MusclesTableTableManager(_db.attachedDatabase, _db.muscles);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$ExerciseMusclesTableTableManager get exerciseMuscles =>
      $$ExerciseMusclesTableTableManager(
        _db.attachedDatabase,
        _db.exerciseMuscles,
      );
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db.attachedDatabase, _db.routines);
  $$RoutineExercisesTableTableManager get routineExercises =>
      $$RoutineExercisesTableTableManager(
        _db.attachedDatabase,
        _db.routineExercises,
      );
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
