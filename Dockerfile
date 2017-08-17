FROM ruby:2.3.1-slim

RUN apt-get update -qq && \
      apt-get install -y build-essential sqlite3 libsqlite3-dev

ENV APP_ROOT /var/www/docker-sinatra

RUN mkdir -p $APP_ROOT

WORKDIR $APP_ROOT

COPY src/ $APP_ROOT

RUN bundle install --without development

EXPOSE 9292

CMD ["ruby", "bobaapp.rb", "-p", "9292"]
