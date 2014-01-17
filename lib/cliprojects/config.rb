module CliProjects
  class Config
    CONFIG_PATH = "~/.cliproj"
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
      # Options that will be used with "rails new PROJ_NAME" when a new project is created with the --init 'rails' option.
      "rails_options" => "",
      "use_mux" => true,
      "track_hours" => true,
    }

    def self.opts
      @opts ||= begin
        unless File.size?(config_path)
          File.open(config_path, "a") {}
        end
        config = YAML.load(File.read(config_path)) || {}
        defaults.merge(config)
      end
    end

    def self.base_path
      opts["base_path"]
    end

    def self.client_path(client_name)
      File.join(opts["base_path"], opts["clients_folder"], Utils.underscore(client_name))
    end

    def self.project_path(client_name, project_name)
      File.join(client_path(client_name), opts["projects_folder"], Utils.underscore(project_name))
    end

    def self.code_path(client_name, project_name)
      File.join(project_path(client_name, project_name), opts["code_folder"])
    end

    def self.template_path
      File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "templates")
    end

    def self.mux_path(project_name)
      File.expand_path("~/.tmuxinator/#{Utils.underscore(project_name)}.yml")
    end

    def self.client_for_project(project_name)
      project_name = Utils.underscore(project_name)
      clients_path = File.join(opts["base_path"], opts["clients_folder"])
      Dir.foreach(clients_path) do |client_file|
        next if client_file == ".." || client_file == "." || File.file?(File.join(clients_path, client_file))

        Dir.foreach(File.join(clients_path, client_file, opts["projects_folder"])) do |project_file|
          return client_file if project_file == project_name
        end
      end
    end

    def self.mux?
      Config.opts["use_mux"] && system('which mux > /dev/null 2>&1')
    end

    def self.config_path
      File.expand_path(CONFIG_PATH)
    end

    protected 

    def self.defaults
      DEFAULT_HASH
    end
  end
end
