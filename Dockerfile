# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20240130-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.15.7-erlang-26.1.2-debian-bullseye-20240130-slim
#
ARG ELIXIR_VERSION=1.15.7
ARG OTP_VERSION=26.1.2
# ARG DEBIAN_VERSION=bullseye-20240130-slim
ARG ALPINE_VERSION=3.18.6

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-alpine-${ALPINE_VERSION}"
ARG RUNNER_IMAGE="alpine:${ALPINE_VERSION}"

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
# RUN apt-get update -y && apt-get install -y build-essential git \
#     && apt-get clean && rm -f /var/lib/apt/lists/*_*
RUN apk add --no-cache build-base git python3 curl
# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"
ENV DATABASE_URL="ecto://postgres:postgres@10.0.9.100/docker_rel_dev"
ENV SECRET_KEY_BASE="HGF1ekWu4VWXZDLby40lUOJFN2dufDptrfr3C1NwwvZFeWmFYxSvUIFTc9/A/Gt/"
ENV PORT 4050
# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets

# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile
RUN mix phx.digest
# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

# RUN apt-get update -y && \
#   apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates \
#   && apt-get clean && rm -f /var/lib/apt/lists/*_*

# # Set the locale
# RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

RUN apk add --no-cache libstdc++ openssl ncurses-libs
RUN apk add --no-cache bash
RUN apk add --no-cache procps
RUN apk add --no-cache curl

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"
EXPOSE 4050

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/docker_rel ./

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/tini", "--"]

CMD ["/app/bin/server"]
