lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record/import_with_callbacks/version'

Gem::Specification.new do |spec|
  spec.name = 'activerecord-import_with_callbacks'
  spec.version = ActiveRecord::ImportWithCallbacks::VERSION
  spec.authors = ['Emmanuel Turlay', 'Erik Michaels-Ober']
  spec.email = ['emmanuel@instacart.com', 'erik@instacart.com']

  spec.summary = 'A library for bulk importing data using ActiveRecord'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/instacart/activerecord-import_with_callbacks'
  spec.license = 'MIT'

  spec.files = Dir["{lib}/**/*", "Rakefile", "README.*", "LICENSE.*", "activerecord-import_with_callbacks.gemspec"]
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.2'

  spec.add_dependency 'activerecord', '>= 4.1', '< 5.1'
  spec.add_dependency 'activerecord-import', '~> 0.19.1'

  spec.add_development_dependency 'bundler', '~> 1.11'
end
