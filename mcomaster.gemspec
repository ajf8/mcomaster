# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mcomaster/version'

Gem::Specification.new do |gem|
  gem.name          = "mcomaster"
  gem.version       = Mcomaster::VERSION
  gem.authors       = ["Alan F"]
  gem.email         = ["ajf@mcomaster.org"]
  gem.description   = %q{web interface to mcollective}
  gem.summary       = %q{web interface to mcollective}
  gem.homepage      = "http://www.mcomaster.org/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('bundler')
  gem.add_dependency('rails', '3.2.13')
  gem.add_dependency('sqlite3')
  gem.add_dependency('therubyracer')
  gem.add_dependency('sass-rails',   '~> 3.2.3')
  gem.add_dependency('coffee-rails', '~> 3.2.1')
  gem.add_dependency('uglifier', '>= 1.0.3')
  gem.add_dependency('jquery-rails')
  gem.add_dependency('jquery-ui-rails')
  gem.add_dependency('handlebars_assets')
  gem.add_dependency("backbone-rails")
  gem.add_dependency("marionette-rails")
  gem.add_dependency("momentjs-rails")
  gem.add_dependency('uuidtools')
  gem.add_dependency("thin", ">= 1.5.0")
  gem.add_dependency("redis")
  gem.add_dependency("mcollective-client", '~> 2.2.3')
  gem.add_dependency("database_cleaner", ">= 1.0.0.RC1");
#  gem.add_dependency("rspec-rails", ">= 2.12.2", :group => [:development, :test])
#  gem.add_dependency("capybara", ">= 2.0.2", :group => :test)
  gem.add_dependency("database_cleaner", ">= 1.0.0.RC1")
#  gem.add_dependency("email_spec", ">= 1.4.0", :group => :test)
  gem.add_dependency("bootstrap-sass", ">= 2.3.0.0")
  gem.add_dependency("devise", ">= 2.2.3")
  gem.add_dependency("cancan", ">= 1.6.9")
  gem.add_dependency("rolify", ">= 3.2.0")
#  gem.add_dependency("quiet_assets", ">= 1.0.2", :group => :development)
  gem.add_dependency("figaro", ">= 0.6.3")
#  gem.add_dependency("better_errors", ">= 0.7.2", :group => :development)
#  gem.add_dependency("binding_of_caller", ">= 0.7.1", :group => :development, :platforms => [:mri_19, :rbx])
end
