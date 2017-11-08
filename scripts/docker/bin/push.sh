#!/usr/bin/env bash

eval $(docker run --rm \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
  xogroup/aws-cli-git \
  ecr get-login)

if [ "$?" != "0" ]; then
  exit 1
fi

ECR_HOST=352362988575.dkr.ecr.us-east-1.amazonaws.com
ECR_REPOSITORY_NAME=notifications/mobile-pusher
ECR_REPOSITORY_URI=$ECR_HOST/$ECR_REPOSITORY_NAME

docker tag $ECR_REPOSITORY_NAME:$APP_ENV $ECR_REPOSITORY_URI:$APP_ENV
docker push $ECR_REPOSITORY_URI:$APP_ENV