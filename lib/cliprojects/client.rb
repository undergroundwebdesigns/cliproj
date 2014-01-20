module CliProjects
  class Client < Thor
    desc "new CLIENT_NAME", "Creates a new client directory for CLIENT_NAME, according to configured settings."
    option :services
    def new(client_name)
      options[:services] = options[:services] ? options[:services].split(",") : []
      create(client_name, options)
    end

    no_commands do
      def create(client_name, options)
        client_path = Utils.client_path(client_name)
        if Utils.client_exist? client_name
          puts "Could not create client #{client_name} at #{client_path}. File or folder already exists."
          exit(1)
        end

        FileUtils.mkdir_p(client_path)
        Config.global.opts["client_subfolders"].each do |subfolder|
          FileUtils.mkdir_p(File.join(client_path, subfolder))
        end
        Config.client(client_name).save(File.join(client_path, Config::CONFIG_FILE_NAME))

        Config.global.opts["client_root_links"].each do |link|
          File.symlink(File.join(client_path, link), File.join(Config.global.base_path, link))
        end
        FileUtils.mkdir_p(Utils.projects_path(client_name))

        Config.client(client_name).set_services(options[:services])
        Config.client(client_name).services.each do |service_class|
          service_class.new(client_name, options).setup
        end
      end
    end

    desc "remove CLIENT_NAME --confirm", "Removes client folder CLIENT_NAME and all subdirectories."
    option :confirm
    def remove(client_name)
      unless options[:confirm]
        puts "Are you sure you want to delete all files & folders for client  #{client_name}? This will delete all projects association with this client, and this cannot be undone!"
        puts "If you are sure, please re-run this command with the --confirm option."
        exit(1)
      end

      Config.client(client_name).services.each do |service_class|
        service_class.new(client_name).tear_down
      end

      client_path = Utils.client_path(client_name)
      if Utils.client_exist? client_name
        `rm -rf #{client_path}`
      else
        puts "Could not find client directory at #{client_path}. Nothing to do."
      end
    end

    desc "list", "Lists all clients."
    def list
      clients = Config.global.clients
      if clients.empty?
        puts "\nNo clients currently defined.\n\n"
      else
        puts "\nClients:"
        clients.each do |client_name|
          puts "#{client_name}"
        end
        puts "\n\n"
      end
    end
  end
end
