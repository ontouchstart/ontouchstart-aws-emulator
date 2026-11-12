batch:
	# 1. Prepare the directory and ensure the container can write to it
	rm -rf home
	mkdir home
	chmod 777 home
	
	# 2. Build and start the emulator
	docker compose build
	docker compose up -d aws-emulator
	
	# 3. Run the client (The emulator is still running in the background)
	docker compose run --rm app-client
	
	# 4. Clean up everything at once
	docker compose down -v
	rm -rf home

