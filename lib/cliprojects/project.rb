module CliProjects
  class Project < Thor
    desc "new CLIENT_NAME, PROJECT_NAME", "Creates a new project directory for PROJECT_NAME within CLIENT_NAME, according to configured settings."
    option :git_repo
    option :repo_name
    option :init
    def new(client_name, project_name)

      project_path = Config.project_path(client_name, project_name)
      code_path = Config.code_path(client_name, project_name)

      options[:init] = options[:init] ? options[:init].split(",") : []

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

      repo_name = options[:repo_name] || project_name
      CliProjects::Repository.new.create(project_name, repo_name, options)
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

      unless client_name
        puts "Couldn't find a client name for #{project_name}. Are you sure it exists?"
        exit(1)
      end

      services.each do |service_class|
        service_class.new(project_name).clean_up
      end

      project_path = Config.project_path(client_name, project_name)
      if Dir.exist? project_path
        `rm -rf #{project_path}`
      else
        puts "Could not find project directory at #{project_path}. Nothing to do."
      end
    end

    desc "start PROJECT_NAME", "Prepares you for working on PROJECT_NAME."
    def start(project_name)
      project_name = Utils.underscore(project_name)
      commands = []
      services.each do |service_class|
        commands << service_class.new(project_name).start_command
      end
      commands.select! {|cmd| cmd }

      if commands.empty?
        puts "Nothing to do, sorry. Try enabling mux?"
      else
        exec commands.join(" && ")
      end
    end

    desc "list", "Lists all projects and their associated clients."
    def list(target_project_name = nil)
      projects = Config.projects
      if projects.empty?
        puts "\nNo projects currently defined.\n\n"
      else
        puts "\nProjects:"
        projects.each do |project_name, client_name|
          puts "#{client_name.ljust(20)} - #{project_name}"
        end
        puts "\n\n"
      end
    end

    protected

    def services(only = nil)
      only_class_names = only.map {|init| "CliProjects::Services::#{init.capitalize}" } if only
      CliProjects::Services::Base.services.select {|init| !only || only_class_names.include?(init.name) }
    end
  end
end
