FROM ruby:3.3-slim

ENV LANG=C.UTF-8 \
    BUNDLE_PATH=/usr/local/bundle \
    HANAMI_ENV=development

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      postgresql-client \
      libyaml-dev \
      git \
      curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock* ./
RUN gem install bundler && bundle install

COPY . .

EXPOSE 2300

CMD ["bin/docker-entrypoint.sh"]
