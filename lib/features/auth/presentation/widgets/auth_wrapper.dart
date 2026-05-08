import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/notes/presentation/pages/notes_page.dart';
import '../bloc/auth_bloc.dart';
import '../pages/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const NotesPage();
        } else if (state is AuthUnauthenticated || state is AuthError) {
          return const LoginPage();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF1976D2)),
          ),
        );
      },
    );
  }
}
