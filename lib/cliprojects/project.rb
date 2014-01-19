module CliProjects
  class Project < Thor
    desc "new CLIENT_NAME, PROJECT_NAME", "Creates a new project directory for PROJECT_NAME within CLIENT_NAME, according to configured settings."
    option :git_repo
    option :repo_name
    option :no_repo, type: :boolean
    option :services
    option :repo_services
    def new(client_name, project_name)
      options[:init] = options[:init] ? options[:init].split(",") : []
      create(client_name, project_name, options)
    end

    no_commands do
      def create(client_name, project_name, options)
        unless Utils.client_exist? client_name
          Client.new.create(client_name, options)
        end

        project_path = Utils.project_path(project_name, client_name)

        if Utils.project_exist? project_name, client_name
          puts "Could not create project #{project_name} at #{project_path}. File or folder already exists."
          exit(1)
        end

        FileUtils.mkdir_p(project_path)
        Config.opts["project_subfolders"].each do |subfolder|
          FileUtils.mkdir_p(File.join(project_path, subfolder))
        end
        FileUtils.mkdir_p(Utils.code_path(project_name))

        Config.opts["project_root_links"].each do |link|
          File.symlink(File.join(project_path, link), File.join(Utils.base_path, link))
        end

        Config.set_project_services(project_name, options[:services])
        Config.project_services(project_name).each do |service_class|
          service_class.new(project_name, options).setup
        end

        unless options[:no_repo]
          repo_options = options
          repo_options[:services] = options[:repo_services]

          repo_name = options[:repo_name] || project_name
          CliProjects::Repository.new.create(project_name, repo_name, repo_options)
        end
      end
    end

    desc "remove PROJECT_NAME --confirm", "Removes project folder PROJECT_NAME and all subdirectories."
    option :confirm
    def remove(project_name)
      unless options[:confirm]
        puts "Are you sure you want to delete all files & folders for project #{project_name}? This cannot be undone!"
        puts "If you are sure, please re-run this command with the --confirm option."
        exit(1)
      end

      client_name = Utils.client_for_project(project_name)
      unless client_name
        puts "Couldn't find a client name for #{project_name}. Are you sure it exists?"
        exit(1)
      end

      Config.project_services(project_name).each do |service_class|
        service_class.new(project_name).tear_down
      end

      project_path = Utils.project_path(project_name)
      if Utils.project_exist? project_name
        `rm -rf #{project_path}`
      else
        puts "Could not find project directory at #{project_path}. Nothing to do."
      end
    end

    desc "start PROJECT_NAME", "Prepares you for working on PROJECT_NAME."
    option :use_services
    option :skip_services
    def start(project_name)
      project_name = Utils.underscore(project_name)
      commands = []
      Config.project_services(project_name, with: options[:use_services], without: options[:skip_services]).each do |service_class|
        commands << service_class.new(project_name).start_command
      end
      commands.select! {|cmd| cmd }

      if commands.empty?
        puts "Nothing to do. Try enabling some init options."
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
  end
end
