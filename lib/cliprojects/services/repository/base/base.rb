module CliProjects::Services::Repository
  class Base < CliProjects::Services::Base
    attr_reader :repository_name, :project_name, :client_name, :repository_path, :project_path, :client_path, :code_path
    def initialize(repo_name, project_name, options = {})
      super(repo_name, options)
      
      @repository_name = repo_name
      @project_name = project_name
      @repository_path = CliProjects::Utils.repository_path(repo_name, project_name)
      @client_name = CliProjects::Utils.client_for_project(project_name)
      @project_path = CliProjects::Utils.project_path(project_name)
      @client_path = CliProjects::Utils.client_path(@client_name)
      @code_path = CliProjects::Utils.code_path(project_name)
    end
  end
end
