module CliProjects
  class ConfigManagement < Thor
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
      "track_hours" => true,
    }

    desc "set KEY=VALUE", "Sets config option KEY to VALUE."
    def set(key_val_string)
      key, val = key_val_string.split("=")
      if val == "true" || val == "false"
        val = val == "true"
      end
      config[key] = val
      File.open(Config.config_path, "w") {|f| f.write YAML.dump(config) }
    end

    desc "get KEY", "Gets the current config value for KEY, or all config values if no KEY given."
    def get(key = nil)
      if key
        val = config[key]
        if val
          puts "#{key}: #{val.inspect}"
        else
          puts "#{key} is not set."
        end
      else
        config.each do |k, v|
          puts "#{k}: #{v.inspect}"
        end
      end
    end

    desc "edit", "Opens the config file for editing"
    def edit
      raise "In order to user the edit command, you must have the $EDITOR environment variable set." unless ENV["EDITOR"]
      exec "$EDITOR #{Config.config_path}"
    end
    
    protected

    def config
      Config.opts
    end
  end
end
