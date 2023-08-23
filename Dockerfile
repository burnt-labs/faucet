FROM 385156030167.dkr.ecr.us-east-1.amazonaws.com/burnt/xiond:sha-79f0d91 AS xiond

FROM golang:alpine AS builder
  WORKDIR /src/app/
  RUN apk add git
  COPY go.mod go.sum* ./
  RUN go mod download
  COPY . .
  RUN CGO_ENABLED=0 go build -o=/usr/local/bin/faucet ./cmd/faucet

FROM alpine
  EXPOSE 8080

  ENV HOME=/home/xiond/.xiond

  COPY --from=builder /usr/local/bin/faucet /usr/local/bin/faucet
  COPY --from=xiond /usr/bin/xiond /usr/local/bin/xiond

  RUN set -eux \
    && apk add --no-cache \
      bash \
      tini

  RUN set -euxo pipefail \
    && addgroup -S xiond \
    && adduser \
       --disabled-password \
       --gecos xiond \
       --ingroup xiond \
       xiond

  RUN set -eux \
    && chown -R xiond:xiond /home/xiond

  USER xiond:xiond
  WORKDIR $HOME

  COPY entrypoint.sh /entrypoint.sh
  ENTRYPOINT ["/entrypoint.sh"]

  CMD [ "faucet" ]
