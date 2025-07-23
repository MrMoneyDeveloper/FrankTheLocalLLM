FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sqlite3 curl git unzip xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ENV FLUTTER_HOME=/opt/flutter
RUN curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.0-stable.tar.xz -o flutter.tar.xz \
    && mkdir -p $FLUTTER_HOME \
    && tar -xJf flutter.tar.xz -C $FLUTTER_HOME --strip-components=1 \
    && rm flutter.tar.xz
ENV PATH=${FLUTTER_HOME}/bin:$PATH

# Install Ollama
RUN curl -fsSL https://ollama.ai/install.sh | sh

