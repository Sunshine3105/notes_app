import '../entities/note.dart';
import '../repositories/note_repository.dart';

class AddNote {
  final NoteRepository repository;

  AddNote(this.repository);

  Future<void> call(Note note) {
    return repository.addNote(note);
  }
}
