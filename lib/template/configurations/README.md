# MY APP

## Prerequisites

- Ruby ≥ 3.3.0
- Rails 7.1

## Local development

### Rails dependencies

  ```shell
bundle install
```

Setup db from schema:

```shell
bundle exec rake db:setup
```

Generate seeds:

```shell
bundle exec rake db:seed
```

### Start local server

```shell
bin/dev
```

The app is accessible on [http://localhost:5000](http://localhost:5000)

### Management of assets

- CSS is built with [tailwindcss-rails](https://github.com/rails/tailwindcss-rails).
- Javascript is managed by [Importmap-rails](https://github.com/rails/importmap-rails) and the [Stimulus](https://github.com/stimulusjs/stimulus) framework.

### Run tests

```shell
bundle exec rspec
```
