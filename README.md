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

Run `make` (or `make help`) to see all targets.

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
