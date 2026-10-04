# E-Market feature brick

Generates a feature using the Brand slice in `features/catalog` as the
architectural baseline:

```text
features/<name>/
├── <name>_domain
├── <name>_data
├── <name>_admin_presentation
└── <name>_customer_presentation
```

The brick initializes every layer with `flutter create --template=package`,
replaces the starter files with the E-Market templates, adds a typed ID to
`shared/domain_primitives`, registers all four packages in the root Dart
workspace, runs `flutter pub get`, and attempts `build_runner` in the domain,
data, admin_presentation, and customer_presentation packages. A code-generation failure is reported but
does not stop the remaining packages or fail feature creation.

The generated data package expects the matching Serverpod client API to exist:

- `<Feature>Dto`
- `EndpointAdmin<Feature>` and `EndpointCustomer<Feature>`

Until those Serverpod client types exist, data-layer AutoMappr generation is
expected to fail. Run `serverpod generate`, then rerun `dart run build_runner
build` from the generated data package.

From the repository root:

```sh
dart pub global activate mason_cli
mason get
mason make feature --name category
```

Commit `mason.yaml` and `bricks/feature`. Do not commit the generated `.mason/`
cache or `mason-lock.json`: local-path brick locks contain a machine-specific
absolute path. On another computer, clone the repository and run `mason get`
before using the brick.
