# Game

##endpoints
POST /api/bowling/start Start Game
GET /api/bowling List Game
POST /api/bowling/roll Roll
GET /api/bowling/:game_id score

#install deps

- Install dependencies with `mix deps.get`

#DB
requires postgress
`mix ecto.setup`

##To start your Phoenix server:

- Start Phoenix endpoint with `mix phx.server`

## Test coverage

MIX_ENV=test mix coveralls

## Run Test

MIX_ENV=test mix test
