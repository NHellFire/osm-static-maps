FROM rust:slim-buster AS oxipng

RUN cargo install oxipng


FROM node:14.15-buster

RUN \
    apt-get update \
    && \
    apt-get install -y \
        libx11-xcb1 \
        libxtst6 \
        libnss3 \
        libxss1 \
        libasound2 \
        libatk-bridge2.0-0 \
        libgtk-3-0 \
        fonts-wqy-zenhei \
        libdrm2 \
        libgbm1 \
    && \
    rm -rf /var/lib/apt/lists/*

COPY --from=oxipng /usr/local/cargo/bin/oxipng /usr/bin/

RUN useradd --system --create-home --home-dir /app app

USER app:app

WORKDIR /app

COPY --chown=app:app package.json .
RUN npm install

COPY --chown=app:app . .

EXPOSE 3000
ENTRYPOINT [ "npm", "start", "--" ]

HEALTHCHECK CMD curl -f http://localhost:3000/health || exit 1
