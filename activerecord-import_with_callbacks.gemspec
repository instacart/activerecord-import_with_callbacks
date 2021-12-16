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

  spec.files = `git ls-files`.split("\n").reject { |f| f.start_with?('spec/') }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.2'

  spec.add_dependency 'activerecord', '>= 4.1', '< 7.1'
  spec.add_dependency 'activerecord-import', '>= 0.19.1', '<= 0.22'

  spec.add_development_dependency 'bundler', '~> 2.2'
end
