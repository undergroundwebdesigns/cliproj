module CliProjects::Services::Client
  class Base < CliProjects::Services::Base

    attr_reader :client_name
    def initialize(client_name, options = {})
      super
      @client_name = client_name
    end
  end
end
