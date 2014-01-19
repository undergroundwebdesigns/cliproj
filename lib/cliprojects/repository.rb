module CliProjects
  class Repository < Thor
    desc "new PROJECT_NAME, REPO_NAME", "Creates a new repository directory for REPO_NAME within PROJECT_NAME code directory, according to configured settings. NOTE: Project MUST already exist or this will throw an error!"
    option :git_repo
    option :init
    def new(project_name, repo_name)

      client_name = Config.client_for_project(project_name)
      unless client_name
        puts "Project name #{project_name} doesn't seem to exist. You must create it before you can create a new repository within it."
        exit(1)
      end

      options[:init] = options[:init] ? options[:init].split(",") : []
      create(project_name, repo_name, options)
    end

    no_commands do
      def create(project_name, repo_name, options)
        repo_path = Config.repo_path(project_name, repo_name)

        if File.exist?(repo_path) || Dir.exist?(repo_path)
          puts "Could not create repo #{repo_name} at #{repo_path}. File or folder already exists."
          exit(1)
        end

        FileUtils.mkdir_p(repo_path)

        if options[:git_repo]
          options[:init] << 'git'
        end

        if options[:init]
          services(options[:init]).each do |service_class|
            service_class.new(project_name, options).set_repo_name(repo_name).init
          end
        end
      end
    end

    protected

    def services(only = nil)
      only_class_names = only.map {|init| "CliProjects::Services::#{init.capitalize}" } if only
      CliProjects::Services::Base.services.select {|init| !only || only_class_names.include?(init.name) }
    end
  end
end
