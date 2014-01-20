module CliProjects::Services::Client
  class Harvest < Base

    attr_reader :harvest
    def initialize(*args)
      super
      @harvest = ::Harvest.client('undergroundwebdevelopment', CliProjects::Config.global.opts["harvest_username"], CliProjects::Config.global.opts["harvest_password"])
    end

    def setup
      client = ::Harvest::Client.new(
        name: client_name,
      )
      client = harvest.clients.create(client)
      CliProjects::Config.client(client_name).set("harvest_id", client.id)
    end

    def tear_down
      # Currently times out, not sure why.
      #client_id = CliProjects::Config.client(client_name).opts["harvest_id"]
      #harvest.clients.delete(client_id) if client_id
    end
  end
end
