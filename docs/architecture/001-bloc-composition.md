# 001: Explicit bootstrap and BLoC provider composition

Status: adopted.

## Context

The admin app needs a Serverpod client, an authenticated session, a selected
shop, and repositories that belong to that shop. Feature packages should
receive domain interfaces without knowing about the client or how
repositories are built.

## Decision

Use explicit bootstrap calls plus `RepositoryProvider` and `BlocProvider`, with
no DI container or task registry. Blocs handle user commands and state;
repositories own data access and DTO mapping.

- `BootstrapRunner` (`shared/app_bootstrap`) initializes Flutter, error
  handlers and the BLoC observer, then runs the app inside one guarded zone.
- `apps/admin/lib/bootstrap.dart` initializes Firebase (only when options are
  configured) and the Serverpod client, then mounts the provider tree. An outer
  `RepositoryProvider<Client>` owns the client and closes it on unmount.
- `AppProviders` binds app-wide repositories (auth, shop) to their interfaces
  and owns `SessionBloc`.
- `AuthenticatedProviders` binds shop-scoped repositories (brand, media). It is
  keyed by the selected shop id, so switching shop or signing out disposes those
  repositories and clears their caches. It is mounted in `MaterialApp.builder`,
  above the root navigator, so dialogs and sheets can read them too.
- `DisposableRepoProvider` creates a repository on first read and calls its
  `dispose` when unmounted.
- `SessionBloc` follows the auth stream and the active shop. Its states
  (`unauthenticated`, `shopRequired`, `ready`) drive the router guard, which
  owns redirects, including the redirect after sign-out.

## Tradeoffs

- Constructor injection is still dependency injection; it just needs no
  container. Provider lookups are checked at runtime, so they stay at widget
  composition boundaries and never inside blocs or repositories.
- Explicit startup calls cannot detect a forgotten initialization step. Add a
  startup pipeline only when several apps or configurable steps repeat enough
  to justify one.
- Unit and widget tests use fakes and do not prove that live Firebase or
  Serverpod authentication works; that needs a runtime smoke test.

## References

- https://engineering.verygood.ventures/architecture/ffca/overview/
- https://bloclibrary.dev/architecture/
- https://bloclibrary.dev/tutorials/flutter-todos/#app (factory, create and
  dispose provider pattern)
- https://docs.flutter.dev/app-architecture/recommendations
