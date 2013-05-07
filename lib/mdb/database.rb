module Mdb
  class Database
    
    
    
    def initialize(file)
      raise FileDoesNotExistError, "\"#{file}\" does not exist" unless File.exist?(file)
      
      @file = file
      @delim = '|' # We're going to assume no pipes in data
    end
    
    
    
    attr_reader :file
    
    
    
    def tables
      @tables ||= execute("mdb-tables -1 #{file_name}").scan(/^\w+$/)
    end
    
    
    
    def columns(table)
      csv = read_csv(table)
      first_line = csv[/^(.*)$/]
      parse_columns(first_line)
    end
    
    
    
    def read_csv(table)
      csv = execute "mdb-export -d \\| #{file_name} #{table}"
      if csv.blank?
        raise TableDoesNotExistError, "#{table.inspect} does not exist in #{file_name.inspect}" if !tables.member?(table.to_s)
        raise Error, "An error occurred when reading #{table.inspect} in #{file_name.inspect}"
      end
      csv
    end
    
    
    
    # Returns an array of hashes. Each hash represents a record
    def each_record(table, &block)
      columns = nil
      read_each(table) do |line|
        if columns
          yield map_to_hash(line.split(@delim), columns)
        else
          columns = parse_columns(line)
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
    
    
    
    def parse_columns(line)
      line.split(@delim).map {|name| name.empty? ? nil : name.to_sym }
    end
    
    
    
    def map_to_hash(values, columns)
      hash = {}
      (0...columns.length).each do |i|
        column = columns[i]
        next if column.nil?
        value = values[i]
        hash[column] = value && value.delete("\"")
      end
      hash
    end
    
    
    
    def read_each(table, &block)
      read_csv(table).each_line do |line|
        yield line.chomp
      end
    end
    
    
    
    def parse(csv)
      csv.split /\n/
    end
    
    
    
    def file_name
      @file.gsub(' ', '\ ')
    end
    
    
    
    def execute(command)
      stdout = ""
      (1..5).each do |try|
        Tempfile.open(rand(99999999).to_s) do |t|
          stdout = `#{command} 2> #{t.path}`
          t.rewind
          stderr = t.read.strip
          break if stderr.blank?
          
          # Rails.logger.error("[mdb-tools] executed `#{command}`; got \"#{stderr}\"")
        end
      end
      
      if stdout.respond_to?(:force_encoding)
        stdout.force_encoding("Windows-1252")
        stdout.encode!("utf-8")
      end
      
      stdout
    end
    
    
    
  end
end
