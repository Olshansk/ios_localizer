# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ios_localizer/version'

Gem::Specification.new do |gem|
  gem.name          = "ios_localizer"
  gem.date          = Date.today
  gem.version       = IosLocalizer::VERSION
  gem.authors       = ["Daniel Olshansky", "Amandeep Grewal"]
  gem.email         = ["olshansky.daniel@gmail.com", "me@amandeep.ca"]
  gem.description   = %q{Uses Google Translate's REST API to properly translate the source Localizable.strings file to each of the specified languages}
  gem.summary       = %q{Localizes iOS applications!}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = ["ios_localizer"] #gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "net/https"
  gem.add_dependency "json"
  gem.add_dependency "cgi"
  gem.add_dependency "htmlentities"
  gem.add_dependency "optparse"
  
end
