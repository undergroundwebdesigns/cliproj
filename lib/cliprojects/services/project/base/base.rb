module CliProjects::Services::Project
  class Base < CliProjects::Services::Base
    attr_reader :project_name, :client_name, :project_path, :client_path, :code_path
    def initialize(project_name, options)
      super
      
      @project_name = project_name
      @client_name = CliProjects::Utils.client_for_project(project_name)
      @project_path = CliProjects::Utils.project_path(project_name)
      @client_path = CliProjects::Utils.client_path(@client_name)
      @code_path = CliProjects::Utils.code_path(project_name)
    end
  end
end
