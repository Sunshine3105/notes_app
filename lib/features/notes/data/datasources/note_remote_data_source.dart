import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

abstract class NoteRemoteDataSource {
  Stream<List<NoteModel>> getNotesStream(String userId);
  Future<void> saveNote(NoteModel note);
  Future<void> deleteNote(String userId, String noteId);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final FirebaseFirestore firestore;

  NoteRemoteDataSourceImpl(this.firestore);

  @override
  Stream<List<NoteModel>> getNotesStream(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NoteModel.fromJson(doc.data()))
              .toList();
        });
  }

  @override
  Future<void> saveNote(NoteModel note) async {
    await firestore
        .collection('users')
        .doc(note.userId)
        .collection('notes')
        .doc(note.id)
        .set(note.toJson());
  }

  @override
  Future<void> deleteNote(String userId, String noteId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }
}
