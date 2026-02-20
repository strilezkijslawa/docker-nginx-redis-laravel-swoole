# First-time setup

## 1. Copy and fill env
cp .env.example .env
###    Set APP_KEY, DB_PASSWORD, DB_ROOT_PASSWORD

## 2. Create a new Laravel project (if not existing)
docker run --rm -v $(pwd)/www:/app composer:2.9 \
    create-project laravel/laravel .

## 3. Install Octane + Swoole driver
docker run --rm -v $(pwd)/www:/app composer:2.9 \
    require laravel/octane
docker compose run --rm app php artisan octane:install --server=swoole

## 4. Build and start
docker compose build
docker compose up -d

## 5. Verify
docker compose ps
curl http://localhost/up

### Tip: After changes in code need to reload octane
docker compose exec app php artisan optimize:clear
docker compose exec app php artisan octane:reload
