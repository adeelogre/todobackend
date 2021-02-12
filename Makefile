# Project vaiables
PROJECT_NAME ?= todobackend
ORG_NAME ?= adeelvm
REPO_NAME ?= todobackend

# Filenames
DEV_COMPOSE_FILE := docker/dev/docker-compose.yml
REL_COMPOSE_FILE := docker/release/docker-compose.yml

# Docker Compose Project Names
REL_PROJECT := $(PROJECT_NAME)$(BUILD_ID)
DEV_PROJECT := $(REL_PROJECT)dev

.PHONY: test build release clean

test:
	${INFO} "Building images..."
	@ sudo docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) build
	${INFO} "Ensuring database is ready..."
	@ sudo docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up agent
	${INFO} "Running tests..."
	@ sudo docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up test
	@ sudo docker cp $$(sudo docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) ps -q test):/reports/. reports
	${INFO} "Testing complete"

build:
	${INFO} "Creating application artifacts..."
	@ sudo docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up builder
	${INFO} "Copying artifacts to target folder..."
	@ sudo docker cp $$(sudo docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) ps -q builder):/wheelhouse/. target
	${INFO} "Build complete"

release:
	${INFO} "Building images..."
	@ sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) build
	${INFO} "Ensuring database is ready..."
	@ sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) up agent
	${INFO} "Collecting static files..."
	@ sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) run --rm app python3 manage.py collectstatic --noinput
	${INFO} "Running database migrations..."
	@ sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) run --rm app python3 manage.py migrate --noinput
	${INFO} "Running acceptance tests..."
	@ sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) up test
	@ sudo docker cp $$(sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) ps -q test):/reports/. reports
	${INFO} "Acceptance testing complete"

clean:
	${INFO} "Destroying development environment..."
	@ sudo docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) kill
	@ sudo docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) rm -f
	${INFO} "Destroying release environment..."
	@ sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) kill
	@ sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) rm -f
	@ #sudo docker images -q -f dangling=true -f label=application=$(REPO_NAME) | xargs -I ARGS  docker rmi -f ARGS
	@ ${INFO} "Removing dangling images, containers and volumes..."
	@ sudo docker system prune -f
	@ sudo docker volume prune -f 
	${INFO} "Clean complete"

# Cosmetics
YELLOW := "\e[1;33m"
NC := "\e[0m"

# Shell Functions
INFO := @bash -c '\
  printf $(YELLOW); \
  echo "=> $$1"; \
  printf $(NC)' SOME_VALUE