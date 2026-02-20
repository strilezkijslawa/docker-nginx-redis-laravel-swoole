ARG PHP_VERSION=8.4

# ─── Composer stage ───────────────────────────────────────────────────────────
FROM composer:2.9 AS composer_stage

# ─── Final image ──────────────────────────────────────────────────────────────
FROM php:${PHP_VERSION}-cli-bookworm

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG TZ=UTC

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=${TZ} \
    USER=laravel \
    ROOT=/var/www/html \
    COMPOSER_FUND=0 \
    COMPOSER_MAX_PARALLEL_HTTP=48

WORKDIR ${ROOT}

SHELL ["/bin/bash", "-eou", "pipefail", "-c"]

# ─── Timezone ─────────────────────────────────────────────────────────────────
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

# ─── PHP extension installer ──────────────────────────────────────────────────
ADD --chmod=0755 \
    https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    /usr/local/bin/

# ─── System dependencies ──────────────────────────────────────────────────────
RUN apt-get update && apt-get upgrade -yqq && \
    apt-get install -yqq --no-install-recommends \
        curl \
        wget \
        git \
        unzip \
        procps \
        ca-certificates \
        supervisor \
        libsodium-dev \
    && apt-get autoremove -y && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ─── PHP extensions ───────────────────────────────────────────────────────────
RUN install-php-extensions \
        pcntl \
        bcmath \
        mbstring \
        sockets \
        pdo_mysql \
        opcache \
        exif \
        zip \
        intl \
        gd \
        redis \
        swoole \
    && docker-php-source delete \
    && rm -rf /tmp/*

# ─── PHP configuration ────────────────────────────────────────────────────────
RUN cp ${PHP_INI_DIR}/php.ini-production ${PHP_INI_DIR}/php.ini

# ─── Non-root user ────────────────────────────────────────────────────────────
RUN groupadd --force -g ${GROUP_ID} ${USER} && \
    useradd -ms /bin/bash --no-log-init --no-user-group -g ${GROUP_ID} -u ${USER_ID} ${USER}

# ─── Composer ─────────────────────────────────────────────────────────────────
COPY --from=composer_stage /usr/bin/composer /usr/bin/composer

# ─── Entrypoint (build context = project root, so path is docker/app/start.sh)
COPY --chmod=0755 docker/app/start.sh /usr/local/bin/start-container

# ─── Application dependencies (cached layer) ──────────────────────────────────
# Copy only composer files first to leverage Docker layer caching.
# www/ is the Laravel app directory; context root is the project root.
COPY --chown=${USER_ID}:${GROUP_ID} www/composer.json www/composer.lock* ./

RUN composer install \
        --no-dev \
        --no-interaction \
        --no-autoloader \
        --no-ansi \
        --no-scripts \
        --no-progress \
    || true

# ─── Application code ─────────────────────────────────────────────────────────
COPY --chown=${USER_ID}:${GROUP_ID} www/ .

RUN mkdir -p \
        storage/framework/{sessions,views,cache,testing} \
        storage/logs \
        bootstrap/cache \
    && chown -R ${USER_ID}:${GROUP_ID} ${ROOT}

USER ${USER}

EXPOSE 8000

ENTRYPOINT ["start-container"]
