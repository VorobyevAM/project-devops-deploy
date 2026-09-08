# syntax=docker/dockerfile:1

FROM node:24-alpine AS frontend-builder
WORKDIR /workspace/frontend

COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build


FROM eclipse-temurin:21-jdk-alpine AS backend-builder
WORKDIR /workspace

COPY gradlew settings.gradle.kts build.gradle.kts ./
COPY gradle/ gradle/
RUN chmod +x gradlew

COPY src/ src/
COPY --from=frontend-builder /workspace/frontend/dist/ src/main/resources/static/
RUN --mount=type=cache,target=/root/.gradle ./gradlew bootJar --no-daemon


FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

ARG APP_VERSION=dev
LABEL org.opencontainers.image.version="${APP_VERSION}"
ENV APP_VERSION="${APP_VERSION}"

RUN addgroup -S app && adduser -S app -G app
COPY --from=backend-builder --chown=app:app /workspace/build/libs/*.jar app.jar

USER app
EXPOSE 8080 9090

ENTRYPOINT ["sh", "-c", "exec java ${JAVA_OPTS:-} -jar app.jar"]
