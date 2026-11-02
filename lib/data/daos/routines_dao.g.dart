// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routines_dao.dart';

// ignore_for_file: type=lint
mixin _$RoutinesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $RoutinesTable get routines => attachedDatabase.routines;
  $RoutineExercisesTable get routineExercises =>
      attachedDatabase.routineExercises;
  $SessionsTable get sessions => attachedDatabase.sessions;
  RoutinesDaoManager get managers => RoutinesDaoManager(this);
}

class RoutinesDaoManager {
  final _$RoutinesDaoMixin _db;
  RoutinesDaoManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db.attachedDatabase, _db.routines);
  $$RoutineExercisesTableTableManager get routineExercises =>
      $$RoutineExercisesTableTableManager(
        _db.attachedDatabase,
        _db.routineExercises,
      );
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db.attachedDatabase, _db.sessions);
}
