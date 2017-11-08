#!/usr/bin/env bash

sed -i "s/_APP_ENV_/$APP_ENV/g" Dockerrun.aws.json
sed -i "s/_SUMOLOGIC_ID_/$SUMOLOGIC_ID/g" .ebextensions/eb_sumologic.config
sed -i "s/_SUMOLOGIC_KEY_/$SUMOLOGIC_KEY/g" .ebextensions/eb_sumologic.config
sed -i "s/_APP_ENV_/$APP_ENV/g" .ebextensions/eb_sumologic.config

git add Dockerrun.aws.json .ebextensions/eb_sumologic.config

if [ "$?" != "0" ]; then
  exit 1
fi

docker run --rm \
  -v $(pwd):/home \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
  xogroup/aws-eb-cli-git \
  use mobile-pusher-$APP_ENV

if [ "$?" != "0" ]; then
  exit 1
fi

docker run --rm \
  -v $(pwd):/home \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
  xogroup/aws-eb-cli-git \
  deploy --staged

if [ "$?" != "0" ]; then
  exit 1
fi

docker run --rm \
  -v $(pwd):/home \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
  xogroup/aws-eb-cli-git \
  labs cleanup-versions --num-to-leave 5 --force

if [ "$?" != "0" ]; then
  exit 1
fi
