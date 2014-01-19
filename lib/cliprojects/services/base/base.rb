module CliProjects::Services
  class Base

    class << self

      def services
        @services.select {|service| service.available? }
      end

      def inherited(subclass)
        @services ||= []
        @services << subclass
      end
    end

    attr_reader :project_name, :client_name, :code_path, :project_name_underscored, :options

    def initialize(project_name, options = {})
      @options = options
      @project_name = project_name
      @client_name = CliProjects::Config.client_for_project(project_name)
      @project_path = CliProjects::Config.project_path(@client_name, @project_name)
      @code_path = CliProjects::Config.code_path(client_name, project_name)
      @project_name_underscored = CliProjects::Utils.underscore(project_name)
    end

    def set_repo_name(repo)
      @repo_name = repo
      self
    end

    def repo_name
      @repo_name || raise("Repo name used but not set.")
    end

    def template_path (file_name)
      @template_path ||= {}
      @template_path[file_name] ||= begin
        custom_path = File.join(CliProjects::Config.opts[:template_overrides_path], self.class.name.split("::").last.downcase, file_name) if CliProjects::Config.opts[:template_overrides_path]
        custom_path && File.exist?(custom_path) ? custom_path : File.join(File.expand_path(File.dirname(File.dirname(__FILE__))), self.class.name.split("::").last.downcase, 'templates', file_name)
      end
    end

    def init
      raise "Not implemented!"
    end

    def clean_up
    end

    def start_command
    end

    # Can be over-ridden in subclasses to dynamically determine
    # whether the initializer should be considered available.
    def self.available?
      true
    end
  end
end
