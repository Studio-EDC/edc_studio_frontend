FROM ubuntu:22.04 AS build

RUN apt update && apt install -y curl unzip git xz-utils
RUN curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.2-stable.tar.xz
RUN tar xf flutter_linux_3.22.2-stable.tar.xz
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

WORKDIR /app
COPY . .

# Usa variables de entorno pasadas por docker-compose
ARG ENDPOINT_BASE
ARG ENDPOINT_DATA_POND

RUN flutter build web --release \
  --dart-define=ENDPOINT_BASE=$ENDPOINT_BASE \
  --dart-define=ENDPOINT_DATA_POND=$ENDPOINT_DATA_POND

# Imagen final
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
