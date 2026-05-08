import '../entities/note.dart';

abstract class NoteRepository {
  Stream<List<Note>> getNotes();
  Future<void> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String noteId);
  Future<void> syncNotes();
}
