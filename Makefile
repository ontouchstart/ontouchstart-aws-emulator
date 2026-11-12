batch:
	docker compose up -d aws-emulator
	@echo "Waiting for emulator to be healthy..."
	@until curl -k https://127.0.0.1:9297/__admin/health > /dev/null 2>&1; do sleep 1; done
	@echo "Emulator is up. Running client test..."
	docker compose run --rm app-client
	docker compose down -v

build:
	docker compose build

down:
	docker compose down -v
	rm -rf home

up:
	docker compose up
