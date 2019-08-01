# Clickhouse rails

[![Build Status](https://travis-ci.com/vsevolod/clickhouse-rails.svg?branch=master)](https://travis-ci.com/vsevolod/clickhouse-rails)
[![codecov](https://codecov.io/gh/vsevolod/clickhouse-rails/branch/master/graph/badge.svg)](https://codecov.io/gh/vsevolod/clickhouse-rails)

## Install

1. Add to Gemfile
```ruby
gem 'clickhouse-rails'
```

2. Run bundle
```bash
$ bundle install
```

3. Init config files and folders
```bash
$ rails g clickhouse:install
```

4. Change clickhouse.yml at `config/clickhouse.yml` path

## Usage

1. Create migrations
```bash
$ rails g clickhouse:migration add_tmp_table
      create  db/clickhouse/migrate/002_add_tmp_table.rb
```

2. Edit file like this:
```ruby
# db/clickhouse/migrate/002_add_tmp_table.rb
class AddTmpTable < Clickhouse::Rails::Migrations::Base
  def self.up
    create_table :tmp do |t|
      t.date   :date
      t.uint16 :id

      t.engine "MergeTree(date, (date), 8192)"
    end
  end
end
```

3. Run migrations
```bash
$ rake clickhouse:db:migrate
```

You can create class of clickhouse table:
```ruby
# app/models/custom_table.rb
class CustomTable
  include Clickhouse::Table
end
```

And insert rows like this:
```ruby
CustomTable.insert_rows([{a:1, b:2}])
CustomTable.insert_row({a:1, b:2})
```

Alter table migration
```ruby
  alter_table "analytics_table" do
    fetch_column :new_ids, :uint8 # Adds column new_ids or skip it
  end
```

## TODO:

1. Rollback migrations
2. Alter table

## Additional clickhouse links

- [Base gem](https://github.com/archan937/clickhouse)
- [List of data types](https://clickhouse.yandex/docs/en/data_types/)
- [Table engines](https://clickhouse.yandex/docs/en/operations/table_engines/)
