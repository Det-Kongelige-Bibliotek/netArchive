FROM ruby:2.4.1

MAINTAINER Nader <nkh@kb.dk>

RUN mkdir /netarkiv-app
WORKDIR /netarkiv-app
COPY Gemfile /netarkiv-app/Gemfile
COPY Gemfile.lock /netarkiv-app/Gemfile.lock
RUN bundle install
RUN rails db:migrate RAILS_ENV=development  
COPY . /netarkiv-app

RUN chgrp -R 0 /netarkiv-app && \
    chmod -R g=u /netarkive-app


CMD rails s -b 0.0.0.0
