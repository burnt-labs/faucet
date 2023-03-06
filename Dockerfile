FROM burntnetwork/burnt:sha-c9864a6 AS burntd

FROM golang:alpine AS builder
  WORKDIR /src/app/
  RUN apk add git
  COPY go.mod go.sum* ./
  RUN go mod download
  COPY . .
  RUN CGO_ENABLED=0 go build -o=/usr/local/bin/faucet ./cmd/faucet

FROM alpine
  ENV HOME=/home/burntd/.burnt

  COPY --from=builder /usr/local/bin/faucet /usr/local/bin/faucet
  COPY --from=burntd /usr/bin/burntd /usr/local/bin/burntd

  RUN set -eux \
    && apk add --no-cache \
      bash \
      tini

  RUN set -euxo pipefail \
    && addgroup -S burntd \
    && adduser \
       --disabled-password \
       --gecos burntd \
       --ingroup burntd \
       burntd

  RUN set -eux \
    && chown -R burntd:burntd /home/burntd

  USER burntd:burntd
  WORKDIR $HOME

  COPY entrypoint.sh /entrypoint.sh
  ENTRYPOINT ["/entrypoint.sh"]

  CMD [ "faucet" ]
