# zarcube served as static files by static-web-server, at /.

FROM --platform=$BUILDPLATFORM node:22-alpine AS build
WORKDIR /src
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund --ignore-scripts
COPY . .
RUN npx vite build --base /

# static-web-server: a single memory-safe (Rust) binary on an empty base,
# run as "nobody". Config in docker/sws.toml.
FROM joseluisq/static-web-server:2
LABEL org.opencontainers.image.title="zarcube" \
      org.opencontainers.image.description="Pacific thermocline data cube: monthly GODAS ocean temperature as an interactive 3D volume" \
      org.opencontainers.image.source="https://github.com/fxi/zarcube" \
      org.opencontainers.image.licenses="MIT"
COPY docker/sws.toml /sws.toml
COPY docker/healthz /public/healthz
COPY --from=build /src/dist /public
USER 65534:65534
EXPOSE 8080
CMD ["--config-file", "/sws.toml"]
