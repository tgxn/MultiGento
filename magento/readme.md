# instructions for bitnami

https://hub.docker.com/r/bitnami/magento

```sh
docker compose --env-file ./envs/one.env exec -it magento /bin/bash  ## Log into the container shell as root
su daemon -s /bin/bash  ## Login as the web server user
cd /bitnami/magento  ## Change directory to the Magento root

## install extension...
composer require m2epro/magento2-extension
# php bin/magento module:enable <extension name>
php bin/magento setup:upgrade
php bin/magento setup:di:compile
php bin/magento setup:static-content:deploy -f
php bin/magento cache:flush
```

/opt/bitnami/php/etc/php.ini

## default extensions

- m2epro/magento2-extension

https://github.com/webkul/magento2-varnish-docker-compose/blob/master/cache_server/default.vcl

# bring up with

`docker compose --env-file ./envs/one.env up -d`
`docker compose --env-file ./envs/two.env up -d`

# run cmd with

`docker compose exec -p customer CMD`

# down with

`docker compose -p one down`
`docker compose --env-file ./envs/one.env logs -f`
`docker compose --env-file ./envs/one.env down`
