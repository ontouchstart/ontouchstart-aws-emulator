batch:
	rm -rf home
	docker compose build
	docker compose up -d aws-emulator
	docker compose down -v
	docker compose run --rm app-client
	docker compose down -v
	rm -rf home

