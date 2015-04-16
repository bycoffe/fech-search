# -*- encoding: utf-8 -*-
require File.expand_path('../lib/fech-search/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Aaron Bycoffe"]
  gem.email         = ["bycoffe@huffingtonpost.com"]
  gem.description   = %q{A Fech plugin for searching electronic FEC filings}
  gem.summary       = %q{Fech-Search provides an interface for searching for electronic filings submitted to the FEC, and accessing the data in those filings using Fech}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "fech-search"
  gem.require_paths = ["lib"]
  gem.version       = Fech::Search::VERSION

  gem.add_dependency "fech", "~> 1.6.2"
  gem.add_dependency "nokogiri", "1.6.6.2"

  gem.add_development_dependency "rspec", "~> 2.13.0"
end
