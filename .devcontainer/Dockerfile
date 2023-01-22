# File: docker_phx/Dockerfile
FROM elixir:1.14-alpine

# install build dependencies
RUN apk add --update git build-base nodejs npm yarn python3

RUN mkdir /app
WORKDIR /app

# install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# set build ENV
ENV MIX_ENV=dev