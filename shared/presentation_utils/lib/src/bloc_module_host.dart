import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Builds a module's surrounding layout with access to its bloc or cubit.
///
/// The `context` is below the module's provider, `bloc` is the instance owned by
/// that provider, and `content` is the module's main widget. A typical use is to
/// place `content` in a page shell and add actions that dispatch events to
/// `bloc`.
///
/// Calling this builder does not subscribe its result to state changes. Wrap
/// state-dependent parts in [BlocBuilder], [BlocSelector], or [BlocListener].
typedef BlocModuleBuilder<B extends BlocBase<Object?>> = Widget Function(
  BuildContext context,
  B bloc,
  Widget content,
);

/// Invokes [builder] from below the module's [BlocProvider].
///
/// Place this widget inside a provider for [B]. The provider retains ownership
/// of the bloc; this host neither creates nor closes it. Without a builder,
/// [content] is returned directly without reading the provider.
class BlocModuleHost<B extends BlocBase<Object?>> extends StatelessWidget {
  /// Creates a composition boundary for provider-owned module content.
  ///
  /// This widget must be placed below a [BlocProvider] that provides [B] when
  /// [builder] is supplied. When [builder] is omitted, [content] is returned
  /// directly and no provider lookup occurs.
  const BlocModuleHost({
    super.key,
    required this.content,
    this.builder,
  });

  /// The module's main widget passed unchanged to [builder].
  ///
  /// The builder decides where to place it, commonly as the body or child of a
  /// page shell.
  final Widget content;

  /// Optionally builds a surrounding layout with access to the provided [B].
  ///
  /// [BlocModuleHost] only exposes the instance. The ancestor [BlocProvider]
  /// retains responsibility for creating and closing it.
  final BlocModuleBuilder<B>? builder;

  @override
  Widget build(BuildContext context) {
    final builder = this.builder;
    if (builder == null) return content;
    return builder(context, context.read<B>(), content);
  }
}
