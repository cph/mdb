require "mdb/version"
require "mdb/database"

module Mdb

  class FileDoesNotExistError < ArgumentError; end
  class TableDoesNotExistError < ArgumentError; end
  class MdbToolsNotInstalledError < ArgumentError
    def message
      "mdbtools is not installed"
    end
  end
  class Error < RuntimeError; end

  def self.open(file)
    Mdb::Database.new(file)
  end

end
