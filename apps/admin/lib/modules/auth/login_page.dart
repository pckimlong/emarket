import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    /// Redirect will auto handled by route guard and app widget reevaluateListenable
    return AdminLoginScreen(authRepo: context.read<IAuthRepo>());
  }
}
