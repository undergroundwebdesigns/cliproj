module CliProjects
  class Repository < Thor
    desc "new PROJECT_NAME, REPO_NAME", "Creates a new repository directory for REPO_NAME within PROJECT_NAME code directory, according to configured settings. NOTE: Project MUST already exist or this will throw an error!"
    option :git_repo
    option :services
    def new(project_name, repo_name)

      unless Utils.project_exist? project_name
        puts "Project name #{project_name} doesn't seem to exist. You must create it before you can create a new repository within it."
        exit(1)
      end

      create(project_name, repo_name, options)
    end

    no_commands do
      def create(project_name, repo_name, options)
        repo_path = Utils.repository_path(repo_name, project_name)

        if Utils.repository_exist? repo_name, project_name
          puts "Could not create repo #{repo_name} at #{repo_path}. File or folder already exists."
          exit(1)
        end

        FileUtils.mkdir_p(repo_path)

        if options[:git_repo]
          options[:services] = Config.services_to_array(options[:services])
          options[:services] << 'git'
        end

        Config.set_repository_services(repo_name, project_name, options[:services])
        Config.repository_services(repo_name, project_name).each do |service_class|
          service_class.new(repo_name, project_name, options).setup
        end
      end
    end

    desc "remove PROJECT_NAME, REPO_NAME", "Removes repository REPO_NAME from project PROJECT_NAME."
    def remove (project_name, repo_name)
      unless options[:confirm]
        puts "Are you sure you want to delete all files & folders for repository #{repo_name} within project #{project_name}? This cannot be undone!"
        puts "If you are sure, please re-run this command with the --confirm option."
        exit(1)
      end

      unless Utils.project_exist? project_name
        puts "Couldn't find project #{project_name}. Are you sure it exists?"
        exit(1)
      end

      Config.repository_services(repo_name, project_name).each do |service_class|
        service_class.new(repo_name, project_name).tear_down
      end

      repo_path = Utils.repository_path(repo_name, project_name)
      if Utils.repository_exist? repo_name, project_name 
        `rm -rf #{repo_path}`
      else
        puts "Could not find repository directory at #{repo_path}. Nothing to do."
      end
    end
  end
end
