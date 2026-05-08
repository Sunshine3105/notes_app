import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();
  @override
  List<Object> get props => [];
}

class NotesSubscriptionRequested extends NotesEvent {}

class NoteAdded extends NotesEvent {
  final String title;
  final String content;

  const NoteAdded(this.title, this.content);

  @override
  List<Object> get props => [title, content];
}

class NoteUpdated extends NotesEvent {
  final Note note;

  const NoteUpdated(this.note);

  @override
  List<Object> get props => [note];
}

class NoteDeleted extends NotesEvent {
  final String id;

  const NoteDeleted(this.id);

  @override
  List<Object> get props => [id];
}
