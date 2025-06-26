FROM debian:latest

# Instala dependencias
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    libgconf-2-4 \
    gdb \
    libstdc++6 \
    libglu1-mesa \
    fonts-droid-fallback \
    lib32stdc++6 \
    python3 \
    ca-certificates \
    gnupg \
    software-properties-common \
    xvfb \
    libxi6 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxrandr2 \
    libasound2 \
    libatk1.0-0 \
    libgtk-3-0 \
    libnss3 \
    libxss1 \
    libx11-xcb-dev \
    && apt-get clean

# Instalar Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install -y ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb

# Clona Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
WORKDIR /usr/local/flutter
RUN git checkout tags/3.32.4

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor
RUN flutter config --enable-web

# Añade el código fuente
WORKDIR /app
COPY . .

RUN flutter pub get

EXPOSE 3000

# Ejecutar Flutter en modo desarrollo sobre Chrome headless
CMD ["flutter", "run", "-d", "web-server", "--web-port=3000", "--web-hostname=0.0.0.0"]
