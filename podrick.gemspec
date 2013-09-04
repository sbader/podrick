# -*- encoding: utf-8 -*-
require File.expand_path('../lib/podrick/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "podrick"
  gem.author        = "Scott Bader"
  gem.email         = "sbader2@gmail.com"
  gem.summary       = "A simple library to work with podcasts"
  gem.description   = "Podrick is a library that allows you to quickly, and easily work with a podcast feed. You can parse a feed, see the newest episodes, and download files"
  gem.homepage      = "http://sbader.github.com/podrick"
  gem.license       = "MIT"

  gem.version       = Podrick::VERSION

  gem.executables   = []
  gem.files         = `git ls-files | grep -v pod`.split("\n")
  gem.test_files    = `git ls-files -- test/*`.split("\n")
  gem.require_paths = ["lib"]

  gem.add_dependency                  'faraday', '~> 0.8.5'
  gem.add_dependency                  'nokogiri', '~> 1.5.6'
  gem.add_development_dependency      'minitest', '~> 4'
  gem.add_development_dependency      'webmock', '~> 1.9'
end
