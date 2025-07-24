#!/usr/bin/env bash
set -euo pipefail

npm run lint
npm test -- --run
pytest backend/tests

# run migrations in sqlite docker
docker run --rm -v $(pwd)/src/Infrastructure/Migrations:/migrations -v $(pwd)/tmp:/data nouchka/sqlite3 sqlite3 /data/test.db < /migrations/0001_initial.sql
