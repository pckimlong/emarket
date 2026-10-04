import 'package:auth_domain/auth_domain.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/flutter_login.dart';

import '../bloc/auth_action_cubit.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({
    required this.authRepo,
    this.onLoginCompleted,
    super.key,
  });

  final IAuthRepo authRepo;
  final VoidCallback? onLoginCompleted;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AuthActionCubit(authRepo),
    child: _LoginView(onLoginCompleted: onLoginCompleted),
  );
}

class _LoginView extends StatelessWidget {
  const _LoginView({required this.onLoginCompleted});

  final VoidCallback? onLoginCompleted;

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      onLogin: (data) async {
        final success = await context.read<AuthActionCubit>().signIn(
          email: data.name,
          password: data.password,
        );
        return success
            ? null
            : 'Unable to sign in. Check your email, password, and server connection.';
      },
      onRecoverPassword: (_) async => 'Password recovery is not available yet.',
      onSubmitAnimationCompleted: onLoginCompleted,
      hideForgotPasswordButton: true,
      userType: LoginUserType.email,
      messages: LoginMessages(
        userHint: 'Email',
        passwordHint: 'Password',
        loginButton: 'SIGN IN',
      ),
      theme: LoginTheme(
        primaryColor: Theme.of(context).colorScheme.primary,
        accentColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
