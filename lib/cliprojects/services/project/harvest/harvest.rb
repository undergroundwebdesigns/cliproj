module CliProjects::Services::Project
  class Harvest < Base

    attr_reader :harvest
    def initialize(*args)
      super
      @harvest = ::Harvest.client('undergroundwebdevelopment', CliProjects::Config.global.opts["harvest_username"], CliProjects::Config.global.opts["harvest_password"])
    end

    def setup
      client_id = CliProjects::Config.client(CliProjects::Utils.client_for_project(project_name)).opts["harvest_id"]
      project = ::Harvest::Project.new(
        name: project_name,
        client_id: client_id,
      )
      project = harvest.projects.create(project)
      CliProjects::Config.project(project_name).set("harvest_id", project.id)
    end

    def tear_down
      # Currently times out, not sure why.
      #project_id = CliProjects::Config.project(project_name).opts["harvest_id"]
      #harvest.projects.delete(project_id) if project_id
    end
  end
end
