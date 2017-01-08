# How to deploy this stupid thing

* git pull that stupid thing
* write database.yml
adapter: postgresql
username: postgres
pool: 5
timeout: 5000
host: localhost
* psql für alle tabellen ->
CREATE EXTENSION IF NOT EXISTS hstore;CREATE EXTENSION IF NOT EXISTS hstore;
* bin/rake
* bin/bundle install
* bin/rake db:migrate
* bin/rake db:migrate RAILS_ENV=development
* bundle exec rake assets:precompile
* bundle exec rails console

die Rails-Console starten. Mit Rails läßt sich dann der User relativ easy anlegen:

u = User.new(login: 'LOGIN', first_name: 'VORNAME', name: 'NACHNAME', phone: 'TELEFON-NR', role: 'admin', email: 'EMAIL', password: 'PASSWORT', password_confirmation: 'PASSWORT')
u.save

* bin/rails s
