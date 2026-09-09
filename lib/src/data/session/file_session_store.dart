import 'dart:convert';
import 'dart:io';

import '../../domain/entities/portable_session/portable_session.dart';
import '../../domain/entities/portable_session_artifact/portable_session_artifact.dart';
import '../../domain/session/session_port.dart';

/// File-backed [SessionPort] (spec FR-006/FR-008/FR-009).
///
/// Each session lives as one JSON file under `<storeDir>/sessions/`, making
/// every session a self-contained, copyable, relocatable unit that any
/// consumer sharing the package and store path can read (US3). Writes are
/// atomic (temporary file + rename), so a mid-write crash leaves either
/// the old session or an ignored `.tmp` — never a half-written file. A
/// corrupt session file is skipped and reported; it never takes other
/// sessions down with it (SC-005).
class FileSessionStore implements SessionPort {
  /// Root directory holding the `sessions/` subdirectory.
  final Directory storeDir;

  /// Errors encountered by the most recent [load]/[list] call (cleared at
  /// its start), so operators can report skipped sessions while the API
  /// itself never throws on corrupt data.
  final List<String> lastReadErrors = [];

  FileSessionStore(this.storeDir);

  Directory get sessionsDirectory => Directory('${storeDir.path}/sessions');

  File _fileFor(String id) => File('${sessionsDirectory.path}/$id.json');

  @override
  Future<void> save(PortableSession session) async {
    await sessionsDirectory.create(recursive: true);
    final target = _fileFor(session.id);
    final tmp = File('${target.path}.tmp');
    // Atomic write: the rename is the commit point.
    final map = session.toJson();
    // Embed the format version so a future reader can reject unsupported
    // formats (spec FR-011). Absent version = legacy (tolerated).
    map['formatVersion'] = PortableSessionArtifact.version;
    await tmp.writeAsString(jsonEncode(map), flush: true);
    await tmp.rename(target.path);
  }

  @override
  Future<PortableSession?> load(String id) async {
    lastReadErrors.clear();
    final file = _fileFor(id);
    if (!await file.exists()) return null;
    try {
      return _decode(await file.readAsString());
    } on SessionFileException catch (error) {
      lastReadErrors.add(error.message);
      return null;
    } on FormatException {
      lastReadErrors.add('Session "$id" is corrupt and was skipped.');
      return null;
    } on FileSystemException catch (error) {
      lastReadErrors.add('Session "$id" could not be read: ${error.message}');
      return null;
    }
  }

  @override
  Future<List<PortableSession>> list() async {
    lastReadErrors.clear();
    if (!await sessionsDirectory.exists()) return const [];
    final sessions = <PortableSession>[];
    await for (final entity in sessionsDirectory.list()) {
      if (entity is! File) continue;
      final path = entity.path;
      // The atomic-write temp files are ignored everywhere.
      if (path.endsWith('.tmp')) continue;
      if (!path.endsWith('.json')) continue;
      try {
        sessions.add(_decode(await File(path).readAsString()));
      } on SessionFileException {
        // Corrupt session: record and skip — the other sessions stay
        // intact and loadable (FR-009 / SC-005).
        lastReadErrors.add('Session file "$path" is corrupt and was skipped.');
      } on FormatException {
        lastReadErrors.add('Session file "$path" is corrupt and was skipped.');
      } on FileSystemException catch (error) {
        lastReadErrors.add(
          'Session file "$path" could not be read: ${error.message}',
        );
      }
    }
    sessions.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    return sessions;
  }

  @override
  Future<bool> delete(String id) async {
    final file = _fileFor(id);
    if (!await file.exists()) return false;
    try {
      await file.delete();
      return true;
    } on FileSystemException {
      return false;
    }
  }

  /// Decodes and validates one session file's content.
  PortableSession _decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const SessionFileException('session file is not a JSON object');
    }
    final version = decoded['formatVersion'];
    if (version is int && version > PortableSessionArtifact.version) {
      throw SessionFileException(
        'unsupported session format version: $version',
      );
    }
    final id = decoded['id'];
    if (id is! String || id.isEmpty) {
      throw const SessionFileException('session file has no valid id');
    }
    return PortableSession.fromJson(decoded);
  }
}

/// Recoverable store-level error (corrupt/unreadable session data).
class SessionFileException implements Exception {
  final String message;
  const SessionFileException(this.message);

  @override
  String toString() => 'SessionFileException: $message';
}
