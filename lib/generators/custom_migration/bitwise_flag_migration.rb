class BitwiseFlagGenerator < MigrationGenerator
  def manifest
    record do |m|
      m.migration_template(
        'bitwise_flag_migration.rb',
        'db/migrate',
        :assigns => get_local_assigns
      )
  end
end