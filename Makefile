test:
	./gradlew test

start: run

run:
	./gradlew bootRun

update-gradle:
	./gradlew wrapper --gradle-version 9.2.1

update-deps:
	./gradlew versionCatalogUpdate

install:
	./gradlew dependencies

build:
	./gradlew build

IMAGE ?= ghcr.io/vorobyevam/project-devops-deploy
TAG ?= latest

docker-build:
	docker build --tag $(IMAGE):$(TAG) .

docker-run:
	docker run --rm --publish 8080:8080 --publish 9090:9090 $(IMAGE):$(TAG)

docker-push:
	docker push $(IMAGE):$(TAG)

docker-publish:
	docker buildx build --platform linux/amd64 --build-arg APP_VERSION=$(TAG) \
		--tag $(IMAGE):$(TAG) --push .

lint:
	./gradlew spotlessCheck

lint-fix:
	./gradlew spotlessApply

.PHONY: test start run update-gradle update-deps install build lint lint-fix \
	docker-build docker-run docker-push docker-publish
