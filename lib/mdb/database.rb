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
        (csv.readline || []).map(&:to_sym)
      end
    end



    def read_csv(table, &block)
      table = table.to_s
      raise TableDoesNotExistError, "#{table.inspect} does not exist in #{file_name.inspect}" unless tables.member?(table)
      date_flags = "-D '%F %T'"
      date_flags << " -T '%F %T'" if supports_datetime?
      execute "mdb-export #{date_flags} -d #{Shellwords.escape(delimiter)} #{file_name} #{Shellwords.escape(table)}", &block
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

      count
    end



    def file_name
      Shellwords.escape(file)
    end



    def open_csv(table)
      read_csv(table) do |file|
        yield CSV.new(file, col_sep: delimiter)
      end
    end



    def execute(command)
      file = Tempfile.new("mdb")
      unless system "#{command} > #{file.path} 2> /dev/null"
        raise MdbToolsNotInstalledError if $?.exitstatus == 127
        raise Error, "#{command[/^\S+/]} exited with status #{$?.exitstatus}"
      end
      return file.read unless block_given?
      yield file
    ensure
      file.close
      file.unlink
    end



    def supports_datetime?
      return @supports_datetime if instance_variable_defined?(:@supports_datetime)

      version = Gem::Version.new(`mdb-ver -M`.gsub(/mdbtools v/, ""))
      @supports_datetime = version >= Gem::Version.new("0.9.0")
    end



  end
end
