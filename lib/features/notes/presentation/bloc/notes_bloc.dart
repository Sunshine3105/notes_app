import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/update_note.dart';
import '../../domain/entities/note.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotes getNotes;
  final AddNote addNote;
  final UpdateNote updateNote;
  final DeleteNote deleteNote;

  NotesBloc({
    required this.getNotes,
    required this.addNote,
    required this.updateNote,
    required this.deleteNote,
  }) : super(const NotesState()) {
    on<NotesSubscriptionRequested>(_onSubscriptionRequested);
    on<NoteAdded>(_onNoteAdded);
    on<NoteUpdated>(_onNoteUpdated);
    on<NoteDeleted>(_onNoteDeleted);
  }

  Future<void> _onSubscriptionRequested(
    NotesSubscriptionRequested event,
    Emitter<NotesState> emit,
  ) async {
    emit(state.copyWith(status: NotesStatus.loading));

    await emit.forEach<List<Note>>(
      getNotes(),
      onData: (notes) =>
          state.copyWith(status: NotesStatus.success, notes: notes),
      onError: (error, stackTrace) => state.copyWith(
        status: NotesStatus.failure,
        errorMessage: error.toString(),
      ),
    );
  }

  Future<void> _onNoteAdded(NoteAdded event, Emitter<NotesState> emit) async {
    final note = Note(
      id: const Uuid().v4(),
      title: event.title,
      content: event.content,
      userId: 'user_1', // TODO: Get from Auth
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await addNote(note);
    } catch (e) {
      emit(
        state.copyWith(status: NotesStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onNoteUpdated(
    NoteUpdated event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await updateNote(event.note);
    } catch (e) {
      emit(
        state.copyWith(status: NotesStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onNoteDeleted(
    NoteDeleted event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await deleteNote(event.id);
    } catch (e) {
      emit(
        state.copyWith(status: NotesStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
