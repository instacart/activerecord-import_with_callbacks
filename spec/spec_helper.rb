$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'active_record'

spec_dir = Pathname.new File.dirname(__FILE__)
database = spec_dir.join('database.yml')

ActiveRecord::Base.configurations['test'] = YAML.load_file(database)['test']
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.establish_connection(:test)
ActiveRecord::Base.raise_in_transactional_callbacks = true

require_relative 'schema'

Dir[spec_dir.join('models/*.rb')].each { |file| require_relative file }

require 'active_record/import_with_callbacks'

ActiveRecord::Import.require_adapter('postgresql')
