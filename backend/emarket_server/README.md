# emarket_server

This is the starting point for your Serverpod server.

### Quick Start (from Workspace Root via Melos)

From the root of the repository, you can launch the server directly without changing directories:

```sh
# Start Docker and run Serverpod with default admin credentials:
dart run melos run server:dev

# Or simply start Serverpod:
dart run melos run server:start
```

---

### Manual Setup & Running (from `backend/emarket_server`)

1. **Create local passwords configuration** (from template):
   ```sh
   cp config/passwords.yaml.example config/passwords.yaml
   ```

2. **Start Postgres and Redis** (using Docker or Colima):
   ```sh
   docker-compose up -d
   ```

3. **Apply migrations & Start the Serverpod server**:
   ```sh
   # To apply migrations and keep server running:
   dart run bin/main.dart --apply-migrations

   # Or to apply migrations and exit immediately (maintenance mode):
   dart run bin/main.dart --apply-migrations --role maintenance
   ```

When finished, shut down Serverpod with `Ctrl-C` and stop containers:
```sh
docker-compose stop
```

---

### Detailed Workflows & Migration Guide

For comprehensive documentation on:
- Adding features & modifying models (`.spy.yaml`)
- Creating and applying migrations
- Hard-resetting Docker database volumes
- Serverpod runtime roles explanation

See [Serverpod Development & Migrations Guide](../../docs/serverpod_workflow_and_migrations.md).
