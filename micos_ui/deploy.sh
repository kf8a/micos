mix deps.get --only prod
MIX_ENV=prod mix compile
cd assets
webpack --mode production
cd ..
mix phx.digest
MIX_ENV=prod mix ecto.migrate
MIX_ENV=prod mix release
