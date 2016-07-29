# Mdb

[![Gem Version](https://badge.fury.io/rb/mdb.svg)](https://rubygems.org/gems/mdb)
[![Code Climate](https://codeclimate.com/github/cph/mdb.svg)](https://codeclimate.com/github/cph/mdb)
[![Build Status](https://travis-ci.org/cph/mdb.svg)](https://travis-ci.org/cph/mdb)

Wraps [mdb-tools](https://github.com/brianb/mdbtools) for reading Microsoft Access databases

## Installation

Add this line to your application's Gemfile:

    gem 'mdb'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mdb

## Usage

```ruby
database = Mdb.open(PATH_TO_FILE)

# list tables in the database
database.tables 

# read the records in a table
database[:Movies]
```

## Heroku

mdb-tools on heroku requires a custom buildpack.

Here is a sample project using this gem on heroku with configuration instructions:

https://github.com/jkotchoff/heroku_rails_microsoft_access_mdb_example

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
