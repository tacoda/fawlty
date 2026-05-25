#!/usr/bin/env bash
set -e

# Wait for postgres
echo "Waiting for postgres at ${DATABASE_HOST:-db}:5432..."
until bundle exec ruby -rpg -e "PG.connect(ENV['DATABASE_URL']).close" >/dev/null 2>&1; do
  sleep 1
done
echo "Postgres is up."

# Create DB if needed, run migrations
bundle exec hanami db prepare || bundle exec hanami db create
bundle exec hanami db migrate

exec bundle exec hanami server --host 0.0.0.0 --port 2300
