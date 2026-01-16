FROM curlimages/curl@sha256:d94d07ba9e7d6de898b6d96c1a072f6f8266c687af78a74f380087a0addf5d17 AS tzdata

RUN \
    echo "**** download tzdata.zi ****" && \
    curl -L -o tzdata.zi https://raw.githubusercontent.com/eggert/tz/main/tzdata.zi

FROM alpine:latest@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62 AS build

RUN apk update && \
    apk add --no-cache curl jq unzip && \
    rm -rf /var/cache/apk/*

ARG TELERISING_API_VERSION="0.14.9"

RUN \
    echo "**** download telerising-api ****" && \
    url=$(curl -Ls \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/sunsettrack4/telerising-api/releases/tags/v${TELERISING_API_VERSION} \
        | jq -r '.assets[] | select(.name | contains("x86-64_linux")) | .browser_download_url') && \
    curl -sSL $url | busybox unzip - && \
    chmod ug+x telerising/api

FROM frolvlad/alpine-glibc:alpine-3.22@sha256:d88903692a6b87bcea53ad19b407859b0a8a714ee91f8c106cd49a8448b86c8c

WORKDIR /app

RUN addgroup -g 1000 telerising \
    && adduser --shell /sbin/nologin --disabled-password \
    --no-create-home --uid 1000 --ingroup telerising telerising \
    && chown -R telerising:telerising /app

RUN \
    echo "**** install dependencies ****" && \
    apk update && \
    apk add --no-cache \
        tzdata \
        libstdc++ && \
    rm -rf /var/cache/apk/*

COPY --from=tzdata /home/curl_user/tzdata.zi /usr/share/zoneinfo/
COPY --from=build --chown=telerising:telerising /telerising /app

USER telerising

HEALTHCHECK --start-period=10s --start-interval=1s --interval=30s --timeout=5s --retries=3 \
    CMD wget --no-verbose -Y off --tries=1 --spider http://127.0.0.1:5000/ || exit 1

EXPOSE 5000

CMD ["./api"]
