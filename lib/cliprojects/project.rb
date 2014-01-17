module CliProjects
  class Project < Thor
    desc "new CLIENT_NAME, PROJECT_NAME", "Creates a new project directory for PROJECT_NAME within CLIENT_NAME, according to configured settings."
    option :git_repo
    option :init
    def new(client_name, project_name)

      if options[:git_repo] && options[:init]
        puts "Can't checkout a git repo AND initialize a new project! Please choose one or the other."
        exit(1)
      end

      project_path = Config.project_path(client_name, project_name)
      code_path = Config.code_path(client_name, project_name)

      if File.exist?(project_path) || Dir.exist?(project_path)
        puts "Could not create project #{project_name} at #{project_path}. File or folder already exists."
        exit(1)
      end

      FileUtils.mkdir_p(project_path)
      Config.opts["project_subfolders"].each do |subfolder|
        FileUtils.mkdir_p(File.join(project_path, subfolder))
      end
      FileUtils.mkdir_p(code_path)

      Config.opts["project_root_links"].each do |link|
        File.symlink(File.join(project_path, link), File.join(Config.base_path, link))
      end

      if options[:git_repo]
        puts "Attempting to clone #{options[:git_repo]} into #{code_path}"
        `git clone '#{options[:git_repo]}' '#{code_path}'`
      end

      if options[:init]
        case options[:init]
        when "rails"
          proj_folder_name = Utils.underscore(project_name)
          puts "Creating a new rails project in #{code_path}"
          `cd '#{code_path}' && rails new '#{proj_folder_name}' #{Config.opts["rails_options"]} && cd ./#{proj_folder_name} && git init`
          if Config.mux?
            puts "Creating a mux profile for #{project_name}"
            FileUtils.cp(File.join(Config.template_path, "rails", "mux.yml"), Config.mux_path(project_name))
          end
        end
      end

    end

    desc "remove PROJECT_NAME --confirm", "Removes project folder PROJECT_NAME and all subdirectories."
    option :confirm
    def remove(project_name)
      client_name = Config.client_for_project(project_name)
      unless options[:confirm]
        puts "Are you sure you want to delete all files & folders for project #{project_name}? This cannot be undone!"
        puts "If you are sure, please re-run this command with the --confirm option."
        exit(1)
      end

      project_path = Config.project_path(client_name, project_name)
      if Dir.exist? project_path
        `rm -rf #{project_path}`
      else
        puts "Could not find project directory at #{project_path}. Nothing to do."
      end

      if File.exist? Config.mux_path(project_name)
        File.delete Config.mux_path(project_name)
      end
    end

    desc "start PROJECT_NAME", "Prepares you for working on PROJECT_NAME."
    def start(project_name)
      project_name = Utils.underscore(project_name)
      client_name = Config.client_for_project(project_name)
      commands = []
      commands << "mux start #{project_name}" if Config.mux?
      if commands.empty?
        puts "Nothing to do, sorry. Try enabling mux?"
      else
        exec commands.join(" && ")
      end
    end
  end
end
