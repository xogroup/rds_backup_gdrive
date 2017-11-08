#!/usr/bin/env bash

cd /webapp/current

#APP_ENV=$APP_ENV eye load mobile-pusher.eye
bundle exec rpush start -e $RACK_ENV
bundle exec puma -C config/puma.rb