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
      def global
        @global_config ||= new(File.expand_path(File.join(DEFAULT_CONFIG_FILE_PATH, CONFIG_FILE_NAME)), "Global")
      end

      def client(client_name)
        @client_config ||= {}
        @client_config[client_name] ||= new(File.join(Utils.client_path(client_name), CONFIG_FILE_NAME), "Client")
      end

      def project(project_name)
        @project_config ||= {}
        @project_config[project_name] ||= new(File.join(Utils.project_path(project_name), CONFIG_FILE_NAME), "Project")
      end

      def repository(repo_name, project_name)
        @repo_config ||= {}
        @repo_config["#{repo_name}-#{project_name}"] ||= new(File.join(Utils.code_path(project_name), "#{CONFIG_FILE_NAME}-#{repo_name}"), "Repository")
      end

      def defaults
        global.opts
      end

    end

    def initialize(path, type)
      @type = type
      @config_path = path
    end

    def opts
      @opts ||= begin
        unless File.size?(config_path)
          File.open(config_path, "a") {}
        end
        config = YAML.load(File.read(config_path)) || {}
        DEFAULT_HASH.merge(config)
      end
    end

    def get(key)
      opts[key]
    end

    def set(key, val)
      if val == "true" || val == "false"
        val = val == "true"
      end
      opts[key] = val
      configs_to_save = opts.select {|k,v| self.class.defaults[k] != v }
      File.open(config_path, "w") {|f| f.write YAML.dump(configs_to_save) }
    end

    def save(path)
      File.open(path, "w") {|f| f.write YAML.dump(opts) }
    end

    def config_path
      @config_path ||= find_config_path
    end

    def debug?
      true
    end

    def set_services(services)
      services = services_to_array(services)
      set("services", services)
    end

    def services
      services = get("services")
      services.map do |service|
        begin
          Object.const_get "CliProjects::Services::#{@type}::#{service.capitalize}"
        rescue NameError => e
          puts e.message
          nil
        end
      end.keep_if {|s| s}
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
