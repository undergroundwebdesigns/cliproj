#!/usr/bin/env ruby

require 'fileutils'
require 'yaml'
require 'erb'
require 'thor'

Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), 'lib', 'cliprojects', '*.rb')).each { |f| require f }
Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), 'lib', 'cliprojects', 'services', '**', '**', '*.rb')).each { |f| require f }

module CliProjects
  class CliProj < Thor
    desc "config SUBCOMMAND ...ARGS", "configure cliproj, set the root directory and other options."
    subcommand "config", ConfigManagement

    desc "client SUBCOMMAND ...ARGS", "manage clients."
    subcommand "client", Client

    desc "project SUBCOMMAND ...ARGS", "manage projects."
    subcommand "project", Project

    desc "repo SUBCOMMAND ...ARGS", "manage repositories."
    subcommand "repo", Repository
  end
end

CliProjects::CliProj.start(ARGV)
