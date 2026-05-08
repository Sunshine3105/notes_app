import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import '../models/note_model.dart';

abstract class NoteLocalDataSource {
  Future<List<NoteModel>> getNotes();
  Future<void> cacheNotes(List<NoteModel> notes);
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
  Stream<List<NoteModel>> watchNotes();
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final SharedPreferences sharedPreferences;
  final _notesSubject = BehaviorSubject<List<NoteModel>>();
  static const String CACHED_NOTES = 'CACHED_NOTES';

  NoteLocalDataSourceImpl(this.sharedPreferences) {
    // Initialize stream with current data
    _initStream();
  }

  void _initStream() {
    final notes = _getNotesFromPrefs();
    _notesSubject.add(notes);
  }

  List<NoteModel> _getNotesFromPrefs() {
    final jsonList = sharedPreferences.getStringList(CACHED_NOTES);
    if (jsonList != null) {
      return jsonList.map((str) => NoteModel.fromJsonString(str)).toList();
    }
    return [];
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    return _getNotesFromPrefs();
  }

  @override
  Future<void> cacheNotes(List<NoteModel> notes) async {
    final List<String> jsonList = notes
        .map((note) => note.toJsonString())
        .toList();
    await sharedPreferences.setStringList(CACHED_NOTES, jsonList);
    _notesSubject.add(notes);
  }

  @override
  Future<void> addNote(NoteModel note) async {
    final notes = _getNotesFromPrefs();
    notes.insert(0, note); // Add to top
    await cacheNotes(notes);
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    final notes = _getNotesFromPrefs();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      await cacheNotes(notes);
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    final notes = _getNotesFromPrefs();
    final index = notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      // Soft delete
      final note = notes[index].copyWith(
        isDeleted: true,
        isSynced: false,
        updatedAt: DateTime.now(),
      );
      notes[index] = note;
      await cacheNotes(notes);
    }
  }

  @override
  Stream<List<NoteModel>> watchNotes() {
    return _notesSubject.stream.map((notes) {
      return notes.where((n) => !n.isDeleted).toList();
    });
  }
}
