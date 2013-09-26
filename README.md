# WhoWillReviewMyPr
===================

http://who-will-review-my-pr.herokuapp.com
------------------------------------------

App that helps you to figure out who could review your Pull Requests

## Usage

Visit [who-will-review-my-pr](http://who-will-review-my-pr.herokuapp.com) login
with your github account and select a PR you want to be reviewed.

## Development

* clone repository
* make sure Erlang and Elixir is up to date
* run specs `MIX_ENV=test mix do deps.get, compile, test`
* start development server `mix server`
* access your app under [localhost:4000](http://localhost:4000)
* start interactive application console `iex -S mix`

## Technical description

This is a project built with Elixir that uses Dynamo to serve web requests.

Resources:

* [Elixir website](http://elixir-lang.org/)
* [Elixir getting started guide](http://elixir-lang.org/getting_started/1.html)
* [Elixir docs](http://elixir-lang.org/docs)
* [Dynamo source code](https://github.com/elixir-lang/dynamo)
* [Dynamo guides](https://github.com/elixir-lang/dynamo#learn-more)
* [Dynamo docs](http://elixir-lang.org/docs/dynamo)
