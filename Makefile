start:
	rm -rf tmp/pids/server.pid
	bin/rails s -b 0.0.0.0

start-dev:
	rm -rf tmp/pids/server.pid
	bin/rails s

install:
	bundle install

setup:
	bundle install
	yarn install
	yarn build
	yarn build:css
	bin/rails db:migrate

without-production:
	bundle config set --local without 'production'

setup-without-production: without-production setup
	cat .env.github .env.sentry | sort > .env || true

cleanup:
	bin/rails db:drop db:create db:migrate

check: test lint

lint:
	bundle exec rubocop -a
	bundle exec slim-lint app/views/

test:
	bin/rails test

.PHONY: test