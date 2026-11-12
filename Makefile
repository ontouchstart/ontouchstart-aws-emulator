build:
	docker compose build
down:
	docker compose down -v
	rm -rf home
up:
	docker compose up
health:
	curl -k https://127.0.0.1:9297/__admin/health
