module CliProjects::Services

   # Options that will be used with "rails new PROJ_NAME" when a new project is created with the --init 'rails' option.
  CliProjects::Config::DEFAULT_HASH["rails_options"] = ""

  class Rails < Base
    def init
      puts "Creating a new rails project in #{code_path}"
      `rails new '#{code_path}' #{CliProjects::Config.opts["rails_options"]}`
    end

    def self.available?
      system('which rails > /dev/null 2>&1')
    end
  end
end
