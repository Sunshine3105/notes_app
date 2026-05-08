import 'dart:async';
import '../../../../core/network/network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_data_source.dart';
import '../datasources/note_remote_data_source.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource localDataSource;
  final NoteRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  StreamSubscription? _remoteSubscription;

  NoteRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  }) {
    _init();
  }

  void _init() {
    networkInfo.onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        syncNotes();
        _listenToRemoteUpdates();
      } else {
        _remoteSubscription?.cancel();
      }
    });

    // Check initial connectivity
    networkInfo.isConnected.then((isConnected) {
      if (isConnected) {
        syncNotes();
        _listenToRemoteUpdates();
      }
    });
  }

  void _listenToRemoteUpdates() async {
    final notes = await localDataSource.getNotes();
    final userId = notes.isNotEmpty ? notes.first.userId : null;
    if (userId == null) {
      return; // Can't listen without userId (maybe get from Auth)
    }

    _remoteSubscription?.cancel();
    _remoteSubscription = remoteDataSource.getNotesStream(userId).listen((
      remoteNotes,
    ) async {
      await _mergeRemoteNotes(remoteNotes);
    });
  }

  Future<void> _mergeRemoteNotes(List<NoteModel> remoteNotes) async {
    final localNotes = await localDataSource.getNotes();
    final localNotesMap = {for (var n in localNotes) n.id: n};
    bool hasChanges = false;

    // 1. Process Remote Notes
    for (var remoteNote in remoteNotes) {
      final localNote = localNotesMap[remoteNote.id];

      if (localNote == null) {
        // New from remote -> Add to local
        localNotes.add(remoteNote.copyWith(isSynced: true));
        hasChanges = true;
      } else {
        // Exists locally
        if (localNote.isSynced) {
          // Local is synced, so remote is newer -> Update local
          if (localNote != remoteNote) {
            localNotes[localNotes.indexOf(localNote)] = remoteNote.copyWith(
              isSynced: true,
            );
            hasChanges = true;
          }
        } else {
          // Local has Unsynced changes.
          // CONFLICT STRATEGY: LOCAL WINS (Keep local dirty state)
          // We do nothing, and rely on next sync to push local to remote.
        }
      }
      // Remove handled note from map to track deletions
      localNotesMap.remove(remoteNote.id);
    }

    // 2. Handle Deletions (Notes in local but not in remote)
    // If a note is in local (and marked as synced) but NOT in remote, it means it was deleted remotely.
    for (var entry in localNotesMap.entries) {
      final localNote = entry.value;
      if (localNote.isSynced && !localNote.isDeleted) {
        // Deleted remotely -> Delete locally
        localNotes.removeWhere((n) => n.id == localNote.id);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await localDataSource.cacheNotes(localNotes);
    }
  }

  @override
  Stream<List<Note>> getNotes() {
    return localDataSource.watchNotes().map((models) {
      models.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return models;
    });
  }

  @override
  Future<void> addNote(Note note) async {
    final noteModel = NoteModel.fromEntity(note).copyWith(isSynced: false);
    await localDataSource.addNote(noteModel);
    _trySync();
  }

  @override
  Future<void> updateNote(Note note) async {
    final noteModel = NoteModel.fromEntity(
      note,
    ).copyWith(isSynced: false, updatedAt: DateTime.now());
    await localDataSource.updateNote(noteModel);
    _trySync();
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await localDataSource.deleteNote(noteId);
    _trySync();
  }

  // Helper to trigger sync if connected
  void _trySync() async {
    if (await networkInfo.isConnected) {
      syncNotes();
    }
  }

  @override
  Future<void> syncNotes() async {
    if (!await networkInfo.isConnected) return;

    final localNotes = await localDataSource.getNotes();
    // We only care about unsynced notes
    final unsyncedNotes = localNotes.where((n) => !n.isSynced).toList();

    if (unsyncedNotes.isEmpty && _remoteSubscription == null) {
      // If no unsynced notes, ensure we are listening to remote
      _listenToRemoteUpdates();
      return;
    }

    for (var note in unsyncedNotes) {
      try {
        if (note.isDeleted) {
          await remoteDataSource.deleteNote(note.userId, note.id);
          // Remove strictly from local after delete confirmed
          // Or mark as synced=true and keep it as deleted?
          // LocalDataSource.deleteNote does "soft delete".
          // If confirmed delete, we might want to hard delete OR just mark synced.
          // Let's hard delete to clean up storage if confirmed.
          final currentNotes = await localDataSource.getNotes();
          currentNotes.removeWhere((n) => n.id == note.id);
          await localDataSource.cacheNotes(currentNotes);
        } else {
          await remoteDataSource.saveNote(note.copyWith(isSynced: true));
          await localDataSource.updateNote(note.copyWith(isSynced: true));
        }
      } catch (e) {
        // sync failed for this note, skip
      }
    }

    // After pushing, ensure we listen
    _listenToRemoteUpdates();
  }
}
