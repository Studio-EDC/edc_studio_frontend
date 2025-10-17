# Etapa 1: build Flutter web
FROM ubuntu:22.04 as build
RUN apt-get update && apt-get install -y git curl unzip ca-certificates && apt-get clean
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
WORKDIR /usr/local/flutter
RUN git checkout tags/3.32.4
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter doctor
RUN flutter config --enable-web

# Crea carpeta de trabajo
WORKDIR /app

# Copia archivos del proyecto
COPY . .

# Construye la aplicación Flutter Web
RUN flutter build web --release

# Etapa 2: Nginx con configuración dinámica de entorno
FROM nginx:alpine

# Copia el build del frontend
COPY --from=build /app/build/web /usr/share/nginx/html

# Copia el template de variables
COPY env.template.js /usr/share/nginx/html/env.template.js

# Instala gettext para usar envsubst
RUN apk add --no-cache gettext

# Crea script de arranque que reemplaza variables de entorno en runtime
RUN echo '#!/bin/sh\n\
echo "Generando env.js con variables de entorno..."\n\
envsubst < /usr/share/nginx/html/env.template.js > /usr/share/nginx/html/env.js\n\
echo "Iniciando Nginx..."\n\
exec nginx -g "daemon off;"' > /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80
