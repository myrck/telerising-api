FROM alpine:latest@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412 AS build

RUN apk update && \
    apk add --no-cache curl jq unzip && \
    rm -rf /var/cache/apk/*

ARG TELERISING_API_VERSION="0.14.7"

RUN \
    echo "**** download telerising-api ****" && \
    url=$(curl -Ls \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/sunsettrack4/telerising-api/releases/tags/v${TELERISING_API_VERSION} \
        | jq -r '.assets[] | select(.name | contains("x86-64_linux")) | .browser_download_url') && \
    curl -sSL $url | busybox unzip - && \
    chmod ug+x telerising/api

FROM debian:stable-slim@sha256:d6743b7859c917a488ca39f4ab5e174011305f50b44ce32d3b9ea5d81b291b3b

WORKDIR /app

RUN groupadd -g 1000 telerising && \
    useradd --shell /sbin/nologin \
        --no-create-home --uid 1000 -g telerising telerising && \
    chown -R telerising:telerising /app

RUN \
    echo "**** install dependencies ****" && \
    apt update && apt install -y --no-install-recommends \
        wget && \
    apt clean && rm -rf /var/lib/apt/lists/*

COPY --from=build --chown=telerising:telerising /telerising /app

USER telerising

HEALTHCHECK --start-period=10s --start-interval=1s --interval=30s --timeout=5s --retries=3 \
    CMD wget --no-verbose -Y off --tries=1 --spider http://127.0.0.1:5000/ || exit 1

EXPOSE 5000

CMD ["./api"]
