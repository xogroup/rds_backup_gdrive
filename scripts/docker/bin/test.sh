#!/usr/bin/env bash

docker-compose -f scripts/docker/compose/$APP_ENV.yml run --rm api

result=$?

docker-compose -f scripts/docker/compose/test.yml stop
docker-compose -f scripts/docker/compose/test.yml rm -v -f

exit $result
