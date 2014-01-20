require 'cliprojects/version'

require 'fileutils'
require 'yaml'
require 'erb'
require 'thor'

require 'cliprojects/client'
require 'cliprojects/config'
require 'cliprojects/config_management'
require 'cliprojects/project'
require 'cliprojects/repository'
require 'cliprojects/utils'
require 'cliprojects/version'

Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), 'lib', 'cliprojects', 'services', '**', '**', '*.rb')).each { |f| require f }
