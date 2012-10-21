# From https://github.com/bmabey/database_cleaner/blob/master/lib/database_cleaner/data_mapper/truncation.rb
module DataMapper
  module Adapters

    class DataObjectsAdapter
      def storage_names(repository = :default)
        raise NotImplementedError
      end
    end

    class MysqlAdapter < DataObjectsAdapter
      # taken from http://github.com/godfat/dm-mapping/tree/master
      def storage_names(repository = :default)
        select 'SHOW TABLES'
      end

      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_name(table_name)};")
      end

      # copied from activerecord
      def disable_referential_integrity
        old = select("SELECT @@FOREIGN_KEY_CHECKS;")
        begin
          execute("SET FOREIGN_KEY_CHECKS = 0;")
          yield
        ensure
          execute("SET FOREIGN_KEY_CHECKS = ?", *old)
        end
      end
    end


    class Sqlite3Adapter < DataObjectsAdapter
      # taken from http://github.com/godfat/dm-mapping/tree/master
      def storage_names(repository = :default)
        # activerecord-2.1.0/lib/active_record/connection_adapters/sqlite_adapter.rb: 177
        sql = <<-SQL
SELECT name
FROM sqlite_master
WHERE type = 'table' AND NOT name = 'sqlite_sequence'
SQL
        # activerecord-2.1.0/lib/active_record/connection_adapters/sqlite_adapter.rb: 181
        select(sql)
      end

      def truncate_table(table_name)
        execute("DELETE FROM #{quote_name(table_name)};")
        execute("DELETE FROM sqlite_sequence where name = '#{table_name}';")
      end

      # this is a no-op copied from activerecord
      # i didn't find out if/how this is possible
      # activerecord also doesn't do more here
      def disable_referential_integrity
        yield
      end
    end

    class SqliteAdapter < DataObjectsAdapter
      # taken from http://github.com/godfat/dm-mapping/tree/master
      def storage_names(repository = :default)
        # activerecord-2.1.0/lib/active_record/connection_adapters/sqlite_adapter.rb: 177
        sql = <<-SQL
SELECT name
FROM sqlite_master
WHERE type = 'table' AND NOT name = 'sqlite_sequence'
SQL
        # activerecord-2.1.0/lib/active_record/connection_adapters/sqlite_adapter.rb: 181
        select(sql)
      end

      def truncate_table(table_name)
        execute("DELETE FROM #{quote_name(table_name)};")
        execute("DELETE FROM sqlite_sequence where name = '#{table_name}';")
      end

      # this is a no-op copied from activerecord
      # since SQLite 3.6.19 the database engine has included the capability to enforce 
      # foreign key constraints but this functionality is disabled by default
      def disable_referential_integrity
        yield
      end
    end

    # FIXME
    # i don't know if this works
    # i basically just copied activerecord code to get a rough idea what they do.
    # i don't have postgres available, so i won't be the one to write this.
    # maybe codes below gets some postgres/datamapper user going, though.
    class PostgresAdapter < DataObjectsAdapter

      # taken from http://github.com/godfat/dm-mapping/tree/master
      def storage_names(repository = :default)
        sql = <<-SQL
SELECT table_name FROM "information_schema"."tables"
WHERE table_schema = current_schema() and table_type = 'BASE TABLE'
SQL
        select(sql)
      end

      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_name(table_name)} RESTART IDENTITY CASCADE;")
      end

      # FIXME
      # copied from activerecord
      def supports_disable_referential_integrity?
        version = select("SHOW server_version")[0][0].split('.')
        (version[0].to_i >= 8 && version[1].to_i >= 1) ? true : false
      rescue
        return false
      end

      # FIXME
      # copied unchanged from activerecord
      def disable_referential_integrity(repository = :default)
        if supports_disable_referential_integrity? then
          execute(storage_names(repository).collect do |name|
            "ALTER TABLE #{quote_name(name)} DISABLE TRIGGER ALL"
          end.join(";"))
        end
        yield
      ensure
        if supports_disable_referential_integrity? then
          execute(storage_names(repository).collect do |name|
            "ALTER TABLE #{quote_name(name)} ENABLE TRIGGER ALL"
          end.join(";"))
        end
      end
    end

  end
end