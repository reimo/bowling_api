# Game

An API to start and and record a bowling game

- Having to support application restart, i when straight to persist game start into postgress db.
- This can be update later to support an in memory store if load and api response time becomes a concern

## endpoints

- POST /api/bowling/start Start Game
- GET /api/bowling List Game
- POST /api/bowling/roll Roll
- GET /api/bowling/:game_id score

## install deps

- Install dependencies with `mix deps.get`

## DB

requires postgress
`mix ecto.setup`

## To start your Phoenix server:

- Start Phoenix endpoint with `mix phx.server`

## Test coverage

MIX_ENV=test mix coveralls

## Run Test

MIX_ENV=test mix test
