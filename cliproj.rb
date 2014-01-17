#!/usr/bin/env ruby

require 'fileutils'
require 'yaml'
require 'thor'

require_relative 'lib/cliprojects/utils'
require_relative 'lib/cliprojects/config'
require_relative 'lib/cliprojects/config_management'
require_relative 'lib/cliprojects/client'
require_relative 'lib/cliprojects/project'

module CliProjects
  class CliProj < Thor
    desc "config SUBCOMMAND ...ARGS", "configure cliproj, set the root directory and other options."
    subcommand "config", ConfigManagement

    desc "client SUBCOMMAND ...ARGS", "manage clients."
    subcommand "client", Client

    desc "project SUBCOMMAND ...ARGS", "manage projects."
    subcommand "project", Project
  end
end

CliProjects::CliProj.start(ARGV)
