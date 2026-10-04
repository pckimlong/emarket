import 'package:admin/app/session_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Keeps the router mounted while authentication state is loading.
class AppSplash extends StatelessWidget {
  const AppSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        return Scaffold(
          body: state.maybeWhen(
            error: (failure) => Center(child: Text(failure.toDebugString())),
            orElse: () => Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
