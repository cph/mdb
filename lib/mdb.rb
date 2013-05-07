require "mdb/version"
require "mdb/database"

module Mdb
  
  class FileDoesNotExistError < ArgumentError; end
  class TableDoesNotExistError < ArgumentError; end
  class Error < RuntimeError; end
  
  def self.open(file)
    Mdb::Database.new(file)
  end
  
end
