# Etapa 1: build Flutter web
FROM ubuntu:22.04 as build
RUN apt-get update && apt-get install -y git curl unzip ca-certificates && apt-get clean
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
WORKDIR /usr/local/flutter
RUN git checkout tags/3.32.4
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter doctor
RUN flutter config --enable-web

WORKDIR /app
COPY . .
RUN touch assets/.env
RUN flutter pub get
RUN flutter build web

# Etapa 2: servir con nginx
FROM nginx:alpine

# Reemplazamos la configuración por una que escuche en el puerto 3000
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]