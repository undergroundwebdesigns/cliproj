lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'cliprojects/version'
Gem::Specification.new do |s|
  s.name        = 'cliproj'
  s.version     = CliProjects::VERSION

  s.authors     = ["Alex Willemsma"]
  s.email       = "alex@undergroundwebdevelopment.com"
  s.summary     = "A cli based project manager."
  s.description = "Allows for the easy creation and management of a clients -> projects -> repos type directory structure, with scripts to template apps, startup scripts, time tracking etc."
  s.require_path = 'lib'
  s.executables = ['cliproj']
  s.files       = Dir.glob("{bin,lib,config}/**/*") + %w(README.md Gemfile cliproj.gemspec)
  s.add_dependency('thor', ">= 0.18.1")
  s.homepage    =
    "https://github.com/undergroundwebdesigns/cliproj"
  s.license       = 'MIT'
end
