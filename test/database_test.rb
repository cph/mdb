require "test_helper"

class MdbTest < ActiveSupport::TestCase


  { "Access 2000" => "Example2000.mdb",
    "Acesss 2003" => "Example2003.mdb" }.each do |format, file|
    path = "#{File.dirname(__FILE__)}/data/#{file}"

    test "should identify three tables in #{file} (#{format})" do
      database = Mdb.open(path)
      assert_equal %w{Actors EmptyTable Movies}, database.tables.sort
    end

    test "should find all the rows in each table (#{format})" do
      database = Mdb.open(path)

      expected_counts = {
        :Actors => 5,
        :Movies => 7 }
      expected_counts.each do |table, expected_count|
        assert_equal expected_count, database[table].count, "The count of '#{table}' is off"
      end
    end
  end



  test "should raise an exception when instatiated with a missing database" do
    assert_raises(Mdb::FileDoesNotExistError) do
      Mdb.open "#{File.dirname(__FILE__)}/data/nope.mdb"
    end
  end

  test "should raise an exception when mdb-tools is not installed" do
    assert_raises(Mdb::MdbToolsNotInstalledError) do
      database = Mdb.open "#{File.dirname(__FILE__)}/data/Example2000.mdb"
      with_env "PATH" => "/nope" do
        database.read :Villains
      end
    end
  end

  context "without permission to read the file" do
    setup do
      system "chmod u-r #{File.dirname(__FILE__)}/data/Protected.mdb"
    end

    teardown do
      system "chmod u+r #{File.dirname(__FILE__)}/data/Protected.mdb"
    end

    should "raise an exception if mdb-tools fails for other reasons" do
      assert_raises(Mdb::Error) do
        database = Mdb.open "#{File.dirname(__FILE__)}/data/Protected.mdb"
        database.read :Actors
      end
    end
  end

  test "should raise an exception if a table is not found" do
    database = Mdb.open "#{File.dirname(__FILE__)}/data/Example2000.mdb"
    assert_raises(Mdb::TableDoesNotExistError) do
      database.read :Villains
    end
  end

  test "should return an empty array if a table is empty" do
    database = Mdb.open "#{File.dirname(__FILE__)}/data/Example2000.mdb"
    assert_equal [], database.read(:EmptyTable)
  end



  test "should return an array of columns for at able" do
    database = Mdb.open "#{File.dirname(__FILE__)}/data/Example2000.mdb"
    assert_equal [:ID, :FirstName, :LastName, :Birthdate], database.columns(:Actors)
  end

  test "should raise an exception if asked for the columns of a nonexistent table" do
    database = Mdb.open "#{File.dirname(__FILE__)}/data/Example2000.mdb"
    assert_raises(Mdb::TableDoesNotExistError) do
      database.columns :Directors
    end
  end

  test "should treat quotation marks correctly" do
    database = Mdb.open "#{File.dirname(__FILE__)}/data/Example2000.mdb"
    actor = database.read(:Actors).first
    assert_equal "Chris", actor[:FirstName] # as opposed to "\"Chris\""
  end

  test "should treat non-ASCII characters correctly" do
    database = Mdb.open "#{File.dirname(__FILE__)}/data/Example2000.mdb"
    actor = database.read(:Actors).last
    assert_equal "Skarsgård", actor[:LastName]
  end



  test "should format dates ISO 8601" do
    database = Mdb.open "#{File.dirname(__FILE__)}/data/Example2000.mdb"
    actor = database.read(:Actors).first
    assert_equal "1981-06-13 00:00:00", actor[:Birthdate]
  end



private

  def with_env(new_env)
    begin
      old_env = ENV.to_hash
      ENV.replace(old_env.merge(new_env))
      yield
    ensure
      ENV.replace(old_env)
    end
  end

end
