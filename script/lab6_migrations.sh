#!/usr/bin/env bash
# Sections 6.1.1-6.1.2 and the exercises on migrating down and up.
#   bash script/lab6_migrations.sh
# Works on the TEST database (recreated from db/schema.rb), so development data is never touched.
set -euo pipefail

export RAILS_ENV=test
snapshot=tmp/schema-before-rollback.rb

bin/rails db:schema:load > /dev/null
cp db/schema.rb "$snapshot"
steps=$(ls db/migrate/*.rb | wc -l | tr -d ' ')

bin/rails db:rollback STEP="$steps"
if grep -q 'create_table "users"' db/schema.rb; then
  echo "FAIL: the users table is still in db/schema.rb after rolling back"
  exit 1
fi
echo "Rollback of $steps migrations removed the users table: PASS"

bin/rails db:migrate
diff "$snapshot" db/schema.rb
echo "Migrating up again restored db/schema.rb exactly: PASS"

bin/rails runner 'puts "columns: #{User.column_names.inspect}"; puts "indexes: #{ActiveRecord::Base.connection.indexes(:users).map { |i| [ i.columns, i.unique ] }.inspect}"'
