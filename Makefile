.DEFAULT_GOAL := build

.PHONY: build docker-build docker deploy

# Install dependencies and build static site
build:
	npm install
	npm run build

# Compile frontend on host and build production docker image
docker-build: build
	docker build --platform linux/amd64 -t rinn7e-elm-realworld .

# Shortcut target for building the docker image
docker: docker-build

# Deploy to Fly.io using the locally built Docker image
deploy:
	@if [ ! -f fly.toml ]; then \
		echo "fly.toml not found, copying from fly.toml.sample..."; \
		cp fly.toml.sample fly.toml; \
	fi
	fly deploy --image rinn7e-elm-realworld --local-only
