# Mdb

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
