# Design decisions

Short records of choices that shape the code. Longer write-ups are numbered
files in this folder.

## Layers and boundaries

- **Apps are the composition root.** `AppProviders` instantiates concrete
  repositories from data packages and binds them to domain interfaces with
  `RepositoryProvider`. Presentation packages read only domain contracts from
  context, so data and presentation never depend on each other.
- **Feature presentation never imports another feature's routes.** Modules
  expose callbacks (`onBrandTapped`, `onSaved`); the app decides where they go.
- **Presentation imports ids and primitives through its domain package.**
  Each domain package re-exports what it needs from `domain_primitives`, so the
  primitives can change without touching presentation code.
- **Intentional duplication over cross-feature coupling.** When a feature needs
  another feature's model in a different shape, it defines its own model.

## Backend and data

- **Serverpod v4.** Embedded PostgreSQL makes Docker optional for local work,
  and adopting v4 during development avoids a later migration of exception
  types, ORM APIs and schema.
- **Serverpod models stay mutable DTOs.** They are mapped to immutable Freezed
  domain models in the data layer. Mutable models keep `extends` simple and
  allow non-constant defaults such as `random_v7` and `now`.
- **AutoMappr generates DTO-to-domain mapping** instead of hand-written mappers.
- **Text ids in the domain.** Typed id wrappers (`BrandId`) hold strings, so the
  domain does not depend on the backend's id type.
- **Admin and customer APIs are separate.** Endpoints, repository
  implementations and interfaces carry an `Admin` or `Customer` prefix
  (`AdminBrandEndpoint`, `AdminBrandRepoImpl`, `IAdminBrandRepo`), because the
  two apps see different data and permissions.
- **`list<Things>` instead of `listAll`.** Leaves room for filters and paging
  without renaming.
- **In-memory list caching only for bounded reference data.**
  `ReactiveListCacheMixin` (stale-while-revalidate) backs masters such as
  brands. High-volume data (products, orders, customers) is queried directly.

## Conventions

- Feature names are singular (`catalog`, `shop`, `staff`).
- New features start from the Mason brick (`bricks/feature`), generated from
  the Brand slice.

## Testing

- Blocs are tested with constructor-injected fake repositories.
- Pages and modules are tested in isolation with `RepositoryProvider.value`
  supplying domain fakes.
- Data repositories are tested against fake Serverpod endpoints.
