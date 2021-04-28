mix deps.get --only prod
MIX_ENV=prod mix compile
npm install --prefix ./assets
npm run deploy --prefix ./assets

#cd assets
#webpack --mode production
#cd ..
mix phx.digest
MIX_ENV=prod mix ecto.migrate
MIX_ENV=prod mix release
