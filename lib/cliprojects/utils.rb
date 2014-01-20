module CliProjects
  class Utils
    class << self
      def underscore(string)
        return nil unless string
        string.gsub(/[\s-]/, "_").downcase
      end

      def client_exist? (client_name)
        client_name = underscore(client_name)
        path = client_path(client_name)
        File.exist?(path) || Dir.exist?(path)
      end

      def project_exist? (project_name, client_name = nil)
        project_name = underscore(project_name)
        path = project_path(project_name, client_name)
        File.exist?(path) || Dir.exist?(path)
      end

      def repository_exist? (repo_name, project_name)
        repo_name = underscore(repo_name)
        path = repository_path(repo_name, project_name)
        File.exist?(path) || Dir.exist?(path)
      end

      def base_path
        Config.opts["base_path"]
      end

      def clients_path
        File.join(Config.opts["base_path"], Config.opts["clients_folder"])
      end

      def client_path(client_name)
        File.join(clients_path, underscore(client_name))
      end

      def projects_path(client_name)
        File.join(client_path(client_name), Config.opts["projects_folder"])
      end

      def project_path(project_name, client_name = nil)
        client_name = client_for_project(project_name) unless client_name
        File.join(projects_path(client_name), underscore(project_name))
      end

      def code_path(project_name)
        File.join(project_path(project_name), Config.opts["code_folder"])
      end

      def repository_path(repo_name, project_name)
        File.join(code_path(project_name), underscore(repo_name))
      end

      def template_path
        File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "templates")
      end

      def mux_path(project_name)
        File.expand_path("~/.tmuxinator/#{underscore(project_name)}.yml")
      end

      def client_for_project(project_name)
        project_name = underscore(project_name)
        Dir.foreach(clients_path) do |client_file|
          next unless non_relative_directory?(clients_path, client_file)

          Dir.foreach(projects_path(client_file)) do |project_file|
            return client_file if project_file == project_name
          end
        end
      end

      def projects
        projects = {}
        return projects unless Dir.exist? base_path
        clients do |client_file|
          Dir.foreach(projects_path(client_file)) do |project_file|
            next unless non_relative_directory?(projects_path(client_file), project_file)
            yield project_file if block_given?
            projects[project_file] = client_file
          end
        end
        projects
      end

      def clients
        clients = []
        return clients unless Dir.exist? base_path
        Dir.foreach(clients_path) do |client_file|
          next unless non_relative_directory?(clients_path, client_file)
          yield client_file if block_given?
          clients << client_file
        end
        clients
      end

      protected 

      def non_relative_directory?(path, file_name)
        File.directory?(File.join(path, file_name)) && file_name != "." && file_name != ".."
      end
    end
  end
end
