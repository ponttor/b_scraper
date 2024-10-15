[![CI Status](https://github.com/ponttor/b_scraper/actions/workflows/main.yml/badge.svg)](https://github.com/ponttor/b_scraper/actions)

## [B Scraper](https://b-scraper-fvsc.onrender.com)

*A service to extract data from Alza.cz.*

*Published on render: https://b-scraper-fvsc.onrender.com*

## Technical specifications and requirements for the project

ruby ​​-v => 3.1.1  
rails -v => 7.2.1  
bootstrap  
slim  
postgres for production environment

## Local installation

```bash
git clone git@github.com:ponttor/b-scraper.git && \
  cd ./b-scraper && \
  make setup
```

## Starting project

```bash
make start-dev
```

## Refreshing database

```bash
make cleanup
```

## Starting tests and linting code

```bash
make check
```

Or start them separately:

```bash
make lint
```

```bash
make test
```

