require File.expand_path("#{File.dirname(__FILE__)}/../rails_spec_helper")

module ActiveRecord
  describe Migration, "#migrate_plugin"do
    before do
      drop_tables
    end

    after do
      drop_tables
    end

    it "creates plugin schema info table" do
      Migration.migrate_plugin('acts_as_spiffy', 2)
      results = select("select * from plugin_schema_info;")
      results.should == [
        {
          'plugin_name' => 'acts_as_spiffy',
          'version' => '2'
        },
      ]
    end

    if ActiveRecord::Migrator.respond_to?(:schema_migrations_table_name)
      describe "after 2.0.2" do
        it "migrates the data" do
          Migration.migrate_plugin('acts_as_spiffy', 2)
          tables = select("show tables")
          table_names = tables.collect do |row|
            row.values.first
          end
          table_names.should == [
            "companies",
            "employees",
            "plugin_schema_info",
            "schema_migrations"
          ]
        end
      end
    else
      describe "up to 2.0.2" do
        it "migrates the data" do
          Migration.migrate_plugin('acts_as_spiffy', 2)
          tables = select("show tables")
          table_names = tables.collect do |row|
            row.values.first
          end
          table_names.should == [
            "companies",
            "employees",
            "plugin_schema_info",
            "schema_info"
          ]
        end
      end
    end

    it "raises error when invalid plugin name passed in" do
      proc do
        Migration.migrate_plugin('acts_as_absent', 2)
      end.should raise_error(ArgumentError, "No plugin found named acts_as_absent")
    end

    def drop_tables
      tables = select("show tables")
      tables.each do |row|
        table_name = row.values.first
        execute_sql "drop table `#{table_name}`"
      end
    end

    def select(sql)
      result_set = []
      stream = execute_sql(sql)
      stream.each_hash do |hash|
        result_set << hash
      end
      result_set
    end

    def execute_sql(sql)
      Base.connection.execute(sql)
    end
  end
end
