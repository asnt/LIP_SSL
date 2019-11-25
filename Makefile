docker:
	# NOTE: Local context is the parent of the `docker/` directory to have access
	# to the downloaded pretrained model in `human/...`.
	docker build -t libssl -f docker/Dockerfile .
