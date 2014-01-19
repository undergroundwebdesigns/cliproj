module CliProjects
  class ConfigManagement < Thor
    desc "set KEY=VALUE", "Sets config option KEY to VALUE."
    def set(key_val_string)
      key, val = key_val_string.split("=")
      if val == "true" || val == "false"
        val = val == "true"
      end
      config[key] = val
      configs_to_save = config.select {|k,v| Config::DEFAULT_HASH[k] != v }
      File.open(Config.config_path, "w") {|f| f.write YAML.dump(configs_to_save) }
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
