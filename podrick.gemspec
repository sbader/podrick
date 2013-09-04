# -*- encoding: utf-8 -*-
require File.expand_path('../lib/podrick/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "podrick"
  gem.author        = "Scott Bader"
  gem.email         = "sbader2@gmail.com"
  gem.summary       = "A simple library to work with podcasts"
  gem.description   = "Podrick is a library that allows you to quickly, and easily work with a podcast feed. You can parse a feed, see the newest episodes, and download files"
  gem.homepage      = "http://sbader.github.com/castpod"
  gem.license       = "MIT"

  gem.version       = Podrick::VERSION

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- test/*`.split("\n")

  gem.add_dependency                  'faraday', '~> 0.8.8'
  gem.add_dependency                  'nokogiri', '~> 1.6.0'
  gem.add_development_dependency      'minitest', '~> 4'
  gem.add_development_dependency      'webmock', '~> 1.9'
end
