.DEFAULT_GOAL := help
COMPOSE       ?= docker compose
BACKEND       := $(COMPOSE) exec backend
FRONTEND      := $(COMPOSE) exec frontend

.PHONY: help install build up down restart logs ps clean nuke \
        backend-shell frontend-shell db-shell \
        db-create db-migrate db-rollback db-seed db-reset db-prepare \
        backend-console backend-test \
        frontend-install frontend-dev frontend-build frontend-lint \
        format

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nFawlty — make targets\n\n"} \
		/^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 } \
		/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) }' $(MAKEFILE_LIST)

##@ Stack

install: ## Build images and install deps
	$(COMPOSE) build

build: install ## Alias for install

up: ## Start the full stack (db, backend, frontend) in the background
	$(COMPOSE) up -d

up-fg: ## Start the full stack in the foreground
	$(COMPOSE) up

down: ## Stop and remove containers
	$(COMPOSE) down

restart: down up ## Restart everything

ps: ## List running services
	$(COMPOSE) ps

logs: ## Tail logs for all services
	$(COMPOSE) logs -f --tail=200

logs-backend: ## Tail backend logs
	$(COMPOSE) logs -f --tail=200 backend

logs-frontend: ## Tail frontend logs
	$(COMPOSE) logs -f --tail=200 frontend

clean: ## Remove containers and orphans (keeps volumes)
	$(COMPOSE) down --remove-orphans

nuke: ## Remove containers AND volumes (destroys DB!)
	$(COMPOSE) down -v --remove-orphans

##@ Shells

backend-shell: ## Open a bash shell inside the backend container
	$(BACKEND) bash

frontend-shell: ## Open a sh shell inside the frontend container
	$(FRONTEND) sh

db-shell: ## Open psql against the dev database
	$(COMPOSE) exec db psql -U postgres -d fawlty_development

##@ Database

db-create: ## Create the database
	$(BACKEND) bundle exec hanami db create

db-migrate: ## Run pending migrations
	$(BACKEND) bundle exec hanami db migrate

db-rollback: ## Roll back the last migration
	$(BACKEND) bundle exec hanami db rollback

db-prepare: ## Create + migrate
	$(BACKEND) bundle exec hanami db prepare

db-seed: ## Load seed data
	$(BACKEND) bundle exec hanami db seed

db-reset: ## Drop, recreate, migrate, seed
	$(BACKEND) bundle exec hanami db drop || true
	$(BACKEND) bundle exec hanami db create
	$(BACKEND) bundle exec hanami db migrate
	$(BACKEND) bundle exec hanami db seed

##@ Backend

backend-console: ## Open a Hanami console
	$(BACKEND) bundle exec hanami console

backend-test: ## Run backend test suite
	$(BACKEND) bundle exec rspec

bundle: ## Run bundle install in the backend container
	$(BACKEND) bundle install

##@ Frontend

frontend-install: ## Install npm deps in the frontend container
	$(FRONTEND) npm install

frontend-dev: ## Run the Vite dev server in foreground (rare, since `up` already does it)
	$(FRONTEND) npm run dev

frontend-build: ## Build the production frontend bundle
	$(FRONTEND) npm run build
