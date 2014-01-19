module CliProjects
  class Client < Thor
    desc "new CLIENT_NAME", "Creates a new client directory for CLIENT_NAME, according to configured settings."
    def new(client_name)
      client_path = Config.client_path(client_name)
      if File.exist?(client_path) || Dir.exist?(client_path)
        puts "Could not create client #{client_name} at #{client_path}. File or folder already exists."
        exit(1)
      end

      FileUtils.mkdir_p(client_path)
      Config.opts["client_subfolders"].each do |subfolder|
        FileUtils.mkdir_p(File.join(client_path, subfolder))
      end

      Config.opts["client_root_links"].each do |link|
        File.symlink(File.join(client_path, link), File.join(Config.base_path, link))
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

      client_path = Config.client_path(client_name)
      if Dir.exist? client_path
        `rm -rf #{client_path}`
      else
        puts "Could not find client directory at #{client_path}. Nothing to do."
      end
    end

    desc "list", "Lists all clients."
    def list
      clients = Config.clients
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
