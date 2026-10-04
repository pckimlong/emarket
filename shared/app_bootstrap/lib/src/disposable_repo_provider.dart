import 'package:data_utils/data_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A [RepositoryProvider] that automatically calls [Disposable.dispose] on any
/// created repository instance that implements [Disposable] when unmounted.
final class DisposableRepositoryProvider<T> extends RepositoryProvider<T> {
  DisposableRepositoryProvider({
    super.key,
    required super.create,
    super.lazy,
    super.child,
  }) : super(
         dispose: (repo) {
           if (repo is Disposable) {
             repo.dispose();
           }
         },
       );
}

/// Short alias for [DisposableRepositoryProvider].
typedef DisposableRepoProvider<T> = DisposableRepositoryProvider<T>;
