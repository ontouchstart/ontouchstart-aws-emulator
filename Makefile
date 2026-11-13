batch:
	# 1. Build and start the emulator
	docker compose build
	docker compose up -d aws-emulator
	
	# 2. Run the s3-client (The emulator is still running in the background)
	docker compose run --rm s3-client

	# 3. Run the dynamodb-client (The emulator is still running in the background)
	docker compose run --rm dynamodb-client
	
	# 4. Clean up everything at once
	docker compose down -v

