module CliProjects
  class Config
    DEFAULT_CONFIG_FILE_PATH = "~/"
    CONFIG_FILE_NAME = ".cliproj"
    DEFAULT_HASH = {
      # The base path, all other created files / folders will be within this:
      "base_path" => File.expand_path("~/business"),
      # The name of the clients folder:
      "clients_folder" => "clients",
      # Subfolders to place in each client's folder:
      "client_subfolders" => ["agreements_and_legal", "documents"],
      # Client subfolders that should be symlinked to the root for easier access:
      "client_root_links" => [],
      # The name of the projects folder inside each client directory:
      "projects_folder" => "projects",
      # Subfolders taht should be added to each project on creation:
      "project_subfolders" => ["notes"],
      # Project subfolders that should be symlinked to the root for easier access:
      "project_root_links" => [],
      # What to call the project's code folder:
      "code_folder" => "code",
    }

    class << self
      def opts
        @opts ||= begin
          unless File.size?(config_path)
            File.open(config_path, "a") {}
          end
          config = YAML.load(File.read(config_path)) || {}
          defaults.merge(config)
        end
      end

      def config_path
        @config_path ||= find_config_path
      end

      def find_config_path
        start_dir = `pwd`
        while (start_dir = File.dirname(start_dir)) && start_dir != "/" do
          file_to_try = File.join(start_dir, CONFIG_FILE_NAME)
          return file_to_try if File.exist? file_to_try
        end
        File.expand_path(File.join(DEFAULT_CONFIG_FILE_PATH, CONFIG_FILE_NAME))
      end

      def debug?
        true
      end

      def set_client_services(client_name, services)
        services = services_to_array(services)
        File.open(File.join(Utils.client_path(client_name), '.cliproj'), "w+") do |f|
          f.write YAML.dump(services)
        end
      end

      def set_project_services(project_name, services)
        services = services_to_array(services)
        File.open(File.join(Utils.project_path(project_name), '.cliproj'), "w+") do |f|
          f.write YAML.dump(services)
        end
      end

      def set_repository_services(repo_name, project_name, services)
        services = services_to_array(services)
        File.open(File.join(Utils.project_path(project_name), ".cliproj-#{repo_name}"), "w+") do |f|
          f.write YAML.dump(services)
        end
      end

      def client_services(client_name)
        services = YAML.load(File.read(File.join(Utils.client_path(client_name), '.cliproj'))) || []
        services.map do |service|
          begin
            "CliProjects::Services::Client::#{service.capitalize}".constantize
          rescue NameError
            nil
          end
        end.keep_if {|s| s}
      end

      def project_services(project_name)
        services = YAML.load(File.read(File.join(Utils.project_path(project_name), '.cliproj'))) || []
        services.map do |service|
          begin
            "CliProjects::Services::Project::#{service.capitalize}".constantize
          rescue NameError
            nil
          end
        end.keep_if {|s| s}
      end

      def repository_services(repo_name, project_name)
        services = YAML.load(File.read(File.join(Utils.project_path(project_name), ".cliproj-#{repo_name}"))) || []
        services.map do |service|
          begin
            Object.const_get("CliProjects::Services::Repository::#{service.capitalize}")
          rescue NameError
            nil
          end
        end.keep_if {|s| s}
      end

      def defaults
        DEFAULT_HASH
      end

      def services_to_array(services)
        case services
        when Array
          services
        when String
          services.split(",")
        when nil
          []
        else
          raise "Invalid services given. Should be a comma separated list (with no spaces)."
        end
      end
    end
  end
end
