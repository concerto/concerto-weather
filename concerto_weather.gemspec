$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "concerto_weather/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "concerto_weather"
  s.version     = ConcertoWeather::VERSION
  s.authors     = ["Brian Michalski"]
  s.email       = ["bmichalski@gmail.com"]
  s.homepage    = "https://github.com/concerto/concerto-weather"
  s.summary     = "Weather plugin for Concerto 2."
  s.description = "Show the current weather and a short forecast in the sidebar of Concerto 2."
  s.license     = 'Apache 2.0'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 3.2.12"

  s.add_development_dependency "sqlite3"
end
