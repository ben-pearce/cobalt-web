FROM node:20-bullseye-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY cobalt /app
COPY patches /patches
RUN npm install --global corepack@latest
RUN corepack enable
RUN apt-get update && \
    apt-get install -y python3 build-essential curl git

RUN rm /app/.git
COPY .git/modules/cobalt /app/.git
RUN cat /app/.git/config
RUN sed -i '/^[[:space:]]*worktree = .*cobalt$/d' /app/.git/config
RUN set -eux; \
    cd /app; \
    for patch in /patches/*.patch; do \
        echo "Applying patch: $patch"; \
        git apply "$patch"; \
    done

WORKDIR /app/web
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile

ARG WEB_HOST
ARG WEB_PLAUSIBLE_HOST
ARG WEB_DEFAULT_API
ENV WEB_HOST=${WEB_HOST}
ENV WEB_PLAUSIBLE_HOST=${WEB_PLAUSIBLE_HOST}
ENV WEB_DEFAULT_API=${WEB_DEFAULT_API}

RUN pnpm run build

FROM node:20-bullseye-slim AS runner

WORKDIR /app

EXPOSE 8080
RUN npm install http-server -g

COPY --from=build /app/web/build ./web/build
WORKDIR /app/web/build
CMD [ "http-server" ]