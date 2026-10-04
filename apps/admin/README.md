# E-Market Admin

The admin Flutter app. It composes feature packages: it binds data
implementations to domain interfaces, owns routing and the session, and turns
feature callbacks into navigation.

Sign-in, shop selection and Brand management work against the Serverpod
backend. The other pages in `lib/modules/` are placeholders.

## Run

Resolve dependencies and generate code from the workspace root (see the root
README), start the Serverpod backend, then from this directory:

```sh
flutter run -t lib/main_dev.dart --dart-define=SERVER_URL=http://localhost:8080/
```

Use a server address reachable from your device or emulator. `main_stage.dart`
and `main_prod.dart` are the other entry points. Firebase is initialized only
when options are supplied in `BootstrapConfig`.

## Reading order

1. `lib/main_dev.dart`: picks the environment and server URL.
2. `lib/bootstrap.dart`: initializes Firebase and Serverpod, and mounts the
   provider tree with the client provider at the top.
3. `lib/app/app_providers.dart`: `AppProviders` (app-wide repositories and
   `SessionBloc`) and `AuthenticatedProviders` (shop-scoped repositories,
   recreated when the selected shop changes).
4. `lib/app/session_bloc.dart`: auth and active-shop state.
5. `lib/app/routing/`: routes and the guard that redirects on session state.
6. `lib/modules/`: route pages that supply repositories and callbacks to
   feature modules. `brand/brand_list_page.dart` is the complete example.

Business behavior belongs in `features/`, not in this app. Design reasons are in
[`docs/architecture/`](../../docs/architecture/).

## Tests

```sh
flutter test
```

Tests use fake repositories from `test/helpers/` and need no backend.
