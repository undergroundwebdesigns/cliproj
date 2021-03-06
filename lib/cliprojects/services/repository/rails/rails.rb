module CliProjects::Services::Repository

   # Options that will be used with "rails new PROJ_NAME" when a new project is created with the --init 'rails' option.
  CliProjects::Config.defaults["rails_options"] = ""

  class Rails < Base
    def setup
      repo_path = CliProjects::Utils.repository_path(repository_name, project_name)
      puts "Creating a new rails project in #{repo_path}"
      `rails new '#{repo_path}' #{CliProjects::Config.global.opts["rails_options"]}`
    end

    def self.available?
      system('which rails > /dev/null 2>&1')
    end
  end
end
