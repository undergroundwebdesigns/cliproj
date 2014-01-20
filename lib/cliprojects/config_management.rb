module CliProjects
  class ConfigManagement < Thor
    desc "set KEY=VALUE", "Sets config option KEY to VALUE."
    def set(key_val_string)
      key, val = key_val_string.split("=", 2)
      Config.global.set(key, val)
    end

    desc "get KEY", "Gets the current config value for KEY, or all config values if no KEY given."
    def get(key = nil)
      if key
        val = Config.global.get(key)
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
      exec "$EDITOR #{Config.global.config_path}"
    end
    
  end
end
