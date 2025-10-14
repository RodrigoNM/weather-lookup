FROM ruby:3.3.6

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn


WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN bundle exec rake assets:precompile


EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
