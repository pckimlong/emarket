import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';

@RoutePage()
class TalkerPage extends StatelessWidget {
  const TalkerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final talker = context.read<Talker>();
    return TalkerScreen(talker: talker);
  }
}
