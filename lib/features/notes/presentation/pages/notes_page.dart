import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart'; // Changed from injection.dart
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../widgets/note_item.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import 'add_edit_note_page.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<NotesBloc>()..add(NotesSubscriptionRequested()),
      child: const NotesView(),
    );
  }
}

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        title: Row(
          children: const [
            Icon(Icons.note_alt, color: Color(0xFF1976D2)),
            SizedBox(width: 12),
            Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state.status == NotesStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1976D2)),
            );
          }
          if (state.status == NotesStatus.failure) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          if (state.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add_rounded,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet\nTap + to create one',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: state.notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final note = state.notes[index];
              return NoteItem(
                note: note,
                onTap: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => AddEditNotePage(
                            initialNote: note,
                            onSave: (title, content) {},
                          ),
                        ),
                      )
                      .then((result) {
                        if (result != null && result is Map) {
                          if (result['delete'] == true) {
                            context.read<NotesBloc>().add(NoteDeleted(note.id));
                          } else {
                            context.read<NotesBloc>().add(
                              NoteUpdated(
                                note.copyWith(
                                  title: result['title'],
                                  content: result['content'],
                                ),
                              ),
                            );
                          }
                        }
                      });
                },
                onDelete: () {
                  context.read<NotesBloc>().add(NoteDeleted(note.id));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const AddEditNotePage()))
              .then((result) {
                if (result != null && result is Map) {
                  context.read<NotesBloc>().add(
                    NoteAdded(result['title'], result['content']),
                  );
                }
              });
        },
        label: const Text(
          'New Note',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFE3F2FD),
        foregroundColor: const Color(0xFF1976D2),
      ),
    );
  }
}
