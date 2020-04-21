# frozen_string_literal: true

require 'netrc'
require 'logger'
require 'sequel'
require 'pg'

netrc = Netrc.read(Dir.home + '/.netrc.gpg')
credentials = netrc['database']

micos_cred = netrc['micos']

MICOS =
  Sequel.postgres(
    database: 'micosui',
    host: '192.168.120.16',
    user: micos_cred['login'],
    loggers: [Logger.new($stdout)],
    password: micos_cred['password']
  )

DB =
  Sequel.postgres(
    database: 'metadata',
    host: 'localhost',
    port: 5_430,
    user: credentials['login'],
    loggers: [Logger.new($stdout)],
    password: credentials['password']
  )

micos_points = MICOS[:points]
micos_samples = MICOS[:samples]
db_points = DB[Sequel.qualify(:micosui, :points)]
db_samples = DB[Sequel.qualify(:micosui, :samples)]

DB.transaction do
  last_db_samples = db_samples.order(:updated_at).last
  micos_samples.where(Sequel[:updated_at] > last_db_samples[:updated_at]).all
               .each { |entry| db_samples.insert entry }
  last_db_points = db_points.order(:updated_at).last
  micos_points.where(Sequel[:updated_at] > last_db_points[:updated_at]).all
              .each { |entry| db_points.insert entry }
end
