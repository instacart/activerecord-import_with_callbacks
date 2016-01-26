lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record/import_with_callbacks/version'

Gem::Specification.new do |spec|
  spec.name = 'activerecord-import_with_callbacks'
  spec.version = ActiveRecord::ImportWithCallbacks::VERSION
  spec.authors = ['Emmanuel Turlay', 'Erik Michaels-Ober']
  spec.email = ['emmanuel@instacart.com', 'erik@instacart.com']

  spec.summary = 'TODO: Write a short summary, because Rubygems requires one.'
  spec.description = 'TODO: Write a longer description or delete this line.'
  spec.homepage = "TODO: Put your gem's website or public repo URL here."
  spec.license = 'MIT'

  spec.files = `git ls-files`.split("\n").reject { |f| f.start_with?('spec/') }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.2'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
