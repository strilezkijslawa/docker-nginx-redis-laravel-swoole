.PHONY: up upb stop bash cli logs down build
up:
	docker compose up -d
upb:
	docker compose up -d --build
stop:
	docker compose stop
bash:
	docker compose exec app bash
cli:
	docker compose exec cli bash
logs:
	docker compose logs -f
down:
	docker compose down
build:
	docker compose build
