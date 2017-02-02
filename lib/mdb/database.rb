require "tempfile"
require "shellwords"
require "csv"


module Mdb
  class Database



    def initialize(file, options={})
      file = file.to_path if file.respond_to?(:to_path)
      raise FileDoesNotExistError, "\"#{file}\" does not exist" unless File.exist?(file)

      @file = file
      @delimiter = options.fetch :delimiter, "|"
    end



    attr_reader :file, :delimiter



    def tables
      @tables ||= execute("mdb-tables -1 #{file_name}").scan(/[^\n]+/)
    end



    def columns(table)
      open_csv(table) do |csv|
        line = csv.readline
        unless line || tables.member?(table.to_s)
          raise TableDoesNotExistError, "#{table.inspect} does not exist in #{file_name.inspect}"
        end

        (line || []).map(&:to_sym)
      end
    end



    def read_csv(table)
      csv = execute "mdb-export -D '%F %T' -d \\| #{file_name} #{Shellwords.escape(table)}"
      empty_table!(table) if csv.empty?
      csv
    end



    # Yields a hash for each record
    def each_record(table, &block)
      columns = nil
      read_each(table) do |line|
        if columns
          yield Hash[columns.zip(line)]
        else
          columns = line.map(&:to_sym)
        end
      end
    end
    alias :each :each_record



    # Returns an array of hashes. Each hash represents a record
    def read_records(table)
      hashes = []
      each(table) {|hash| hashes << hash}
      hashes
    end
    alias :read :read_records
    alias :[] :read_records



  private



    def read_each(table, &block)
      count = 0

      open_csv(table) do |csv|
        while line = csv.readline
          yield line
          count += 1
        end
      end

      empty_table!(table) if count == 0

      count
    end



    def empty_table!(table)
      raise TableDoesNotExistError, "#{table.inspect} does not exist in #{file_name.inspect}" if !tables.member?(table.to_s)
      raise Error, "An error occurred when reading #{table.inspect} in #{file_name.inspect}"
    end



    def file_name
      Shellwords.escape(file)
    end



    def open_csv(table)
      command = "mdb-export -D '%F %T' -d #{Shellwords.escape(delimiter)} #{file_name} #{Shellwords.escape(table)}"
      execute(command) do |file|
        yield CSV.new(file, col_sep: delimiter)
      end
    end



    def execute(command)
      file = Tempfile.new("mdb")
      system "#{command} > #{file.path} 2> /dev/null"
      raise MdbToolsNotInstalledError if $?.exitstatus == 127
      return file.read unless block_given?
      yield file
    ensure
      file.close
      file.unlink
    end



  end
end
