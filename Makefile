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
	sudo docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) build
	sudo docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up agent
	sudo docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up test

build:
	sudo docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up builder

release:
	sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) build
	sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) up agent
	sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) run --rm app python3 manage.py collectstatic --noinput
	sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) run --rm app python3 manage.py migrate --noinput
	sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) up test

clean:
	sudo docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) kill
	sudo docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) rm -f -v
	sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) kill
	sudo docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) rm -f -v
	sudo docker images -q -f dangling=true -f label=application=$(REPO_NAME) | xargs -I ARGS  docker rmi -f ARGS