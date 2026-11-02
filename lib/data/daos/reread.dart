import 'package:drift/drift.dart';

/// Turns a one-off read into a live stream: it runs again when a table changes.
extension Reread on DatabaseConnectionUser {
  /// [read]'s result, then again whenever one of [tables] changes.
  Stream<T> rereadOn<T>(
    List<ResultSetImplementation> tables,
    Future<T> Function() read,
  ) async* {
    yield await read();
    await for (final _ in tableUpdates(TableUpdateQuery.onAllTables(tables))) {
      yield await read();
    }
  }
}
