# Fawlty

A hotel-staff web app for managing **rooms**, **guests**, **reservations**, and
**stays** — including check-in and check-out flows.

```
fawlty/
├── backend/       # Hanami 2 API (Ruby + ROM + Postgres)
├── frontend/      # Svelte + Vite SPA
├── docker-compose.yml
└── Makefile       # Wraps the common dev commands
```

## Stack

- **Backend:** Hanami 2.3 (JSON API), `hanami-db` / ROM, PostgreSQL 16, Puma
- **Frontend:** Svelte 4 + Vite 5
- **Orchestration:** Docker Compose
- **Task runner:** GNU Make

## Quickstart

Requires Docker (with Compose v2) and `make`.

```bash
make install     # build images and install deps
make up          # boot db + backend + frontend
make db-seed     # load sample rooms & guests (one time)
```

Then open:

- Frontend UI: <http://localhost:5173>
- Backend API: <http://localhost:2300/api/rooms>

To stop:

```bash
make down
```

To wipe everything (containers + DB volume):

```bash
make nuke
```

## Make targets

`make` (with no arguments) or `make help` prints the full list, grouped and
color-coded from the `##` comments in the `Makefile` itself — that file stays
the source of truth. The three to know on day one are `make install`, `make
up`, and `make db-seed` (see Quickstart above).

### Stack

| Target | What it does |
| --- | --- |
| `install` | Build images and install deps |
| `build` | Alias for install |
| `up` | Start the full stack (db, backend, frontend) in the background |
| `up-fg` | Start the full stack in the foreground |
| `down` | Stop and remove containers |
| `restart` | Restart everything |
| `ps` | List running services |
| `logs` | Tail logs for all services |
| `logs-backend` | Tail backend logs |
| `logs-frontend` | Tail frontend logs |
| `clean` | Remove containers and orphans (keeps volumes) |
| `nuke` | Remove containers AND volumes (destroys DB!) |

### Shells

| Target | What it does |
| --- | --- |
| `backend-shell` | Open a bash shell inside the backend container |
| `frontend-shell` | Open a sh shell inside the frontend container |
| `db-shell` | Open psql against the dev database |

### Database

| Target | What it does |
| --- | --- |
| `db-create` | Create the database |
| `db-migrate` | Run pending migrations |
| `db-rollback` | Roll back the last migration |
| `db-prepare` | Create + migrate |
| `db-seed` | Load seed data |
| `db-reset` | Drop, recreate, migrate, seed |

### Quality

| Target | What it does |
| --- | --- |
| `gate` | Run the commit gate against staged changes |
| `gate-test` | Self-check the commit gate's rules |
| `hooks` | Install the commit gate as .git/hooks/pre-commit |

### Backend

| Target | What it does |
| --- | --- |
| `backend-console` | Open a Hanami console |
| `backend-test` | Run backend test suite |
| `bundle` | Run bundle install in the backend container |

### Frontend

| Target | What it does |
| --- | --- |
| `frontend-install` | Install npm deps in the frontend container |
| `frontend-dev` | Run the Vite dev server in foreground (rare, since `up` already does it) |
| `frontend-build` | Build the production frontend bundle |

## API

All endpoints are JSON, mounted under `/api`.

| Resource       | Routes |
| -------------- | ------ |
| Rooms          | `GET/POST /rooms`, `GET/PATCH/DELETE /rooms/:id` |
| Guests         | `GET/POST /guests`, `GET/PATCH/DELETE /guests/:id` |
| Reservations   | `GET/POST /reservations`, `GET/PATCH/DELETE /reservations/:id`, `POST /reservations/:id/check_in` |
| Stays          | `GET /stays[?active=true]`, `POST /stays`, `GET/PATCH /stays/:id`, `POST /stays/:id/check_out` |

### Workflow

1. Create a **room** and a **guest**.
2. Create a **reservation** linking them with dates.
3. `POST /reservations/:id/check_in` — creates an active **stay**, flips the
   reservation to `checked_in` and the room to `occupied`.
4. `POST /stays/:id/check_out` — closes the stay, flips the reservation to
   `checked_out` and the room to `cleaning`.

## Local development without Docker

Backend:

```bash
cd backend
bundle install
bundle exec hanami db prepare
bundle exec hanami server
```

Frontend:

```bash
cd frontend
npm install
npm run dev
```

The Vite dev server proxies `/api/*` to `http://localhost:2300` by default.
