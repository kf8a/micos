# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Test.Repo.insert!(%Test.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

study = MicosUi.Repo.insert!(%MicosUi.Samples.Study{name: "MCSE"})

File.stream!("plots.csv")
|> Enum.map(&String.trim/1)
|> Enum.map(fn x -> MicosUi.Repo.insert(%MicosUi.Samples.Plot{study_id: study.id, name: x}) end )
