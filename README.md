<img src="../web/public/images/logo.png" height="68" />

# ElixirBench API

[![Travis build](https://secure.travis-ci.org/elixir-bench/elixir-bench-api.svg?branch=master
"Build Status")](https://travis-ci.org/elixir-bench/elixir-bench-api)
[![Coverage Status](https://coveralls.io/repos/github/elixir-bench/elixir-bench-api/badge.svg?branch=master
"Test Coverage")](https://coveralls.io/github/elixir-bench/elixir-bench-api?branch=master)

This project provides a public GraphQL API for exploring the results of the
benchmarks and is responsible for jobs scheduling.

You can explore it's API doc in public [GraphiQL](https://api.elixirbench.org/api/graphiql)
interface.

## Requirements

The projects needs Erlang, Elixir and PostgreSQL installed.

For development, a database user called `postgres` with password `postgres` is required.
If desired otherwise, this configuration can be changed in `config/dev.exs`.

## Getting started

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Set up the database and some sample seed data `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000/api/graphiql`](http://localhost:4000/api/graphiql) from your browser.

## Deployment

This project uses `distillery` for deployments. The relese requires `PORT` and
`DATABASE_URL` environment variables. Built releases are placed under `_build/prod/rel/elixir_bench`
directory

```
$ MIX_ENV=prod mix release --env=prod
```

Start the application passing the required variables

```
DATABASE_URL="postgresql://user:password@localhost:5432/elixir_bench_dev" PORT=4000 _build/prod/rel/elixir_bench/bin/elixir_bench foreground
```

**PS:** If you try to build a release with an environment other than prod, **IT WILL FAIL**
as development and test environments rely on Mix wich is not shipped within the releases and
require substantial changes to work.

## Deploy on Gigalixir

This project ships the configuration needed to deploy on [Gigalixir](https://gigalixir.com), a Heroku like
service. To make a deploy on Gigalixir you will have to follow this simple guide and refer
to the documentation for further information, see [Getting Started](https://gigalixir.readthedocs.io/en/latest/main.html#getting-started-guide)

- Install the Gigalixir CLI, all steps are performed through it
- Create an account and login
- Create an app and give it a name
- Add a database to your app
- Push your code to gigalixir and see the magic happening

**This project uses the `uuid-ossp extension` from postgresql which is added
in `priv/repo/migrations/20171210214237_add_uuid_to_job.exs`. Gigalixir does not
allow any extensions in the free tier plan, so a workaround is to remove it from
the migration to not use this extension or drop a few bucks :)**

## License

ElixirBench API is released under the Apache 2.0 License - see the [LICENSE](LICENSE.md) file.
