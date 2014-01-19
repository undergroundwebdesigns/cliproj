module CliProjects::Services
  class Mux < Base

    def init
      if File.exist? CliProjects::Config.mux_path(project_name)
        puts "Not creating a mux file for #{project_name}. File #{CliProjects::Config.mux_path(project_name)} already exists."
      else
        puts "Creating a mux profile for #{project_name}"
        template_file = File.open(template_path('mux.erb'), 'r').read
        erb = ERB.new(template_file)
        File.open(CliProjects::Config.mux_path(project_name), "w+") do |file|
          file.write(erb.result(binding))
        end
      end
    end

    def clean_up
      if File.exist? CliProjects::Config.mux_path(project_name)
        File.delete CliProjects::Config.mux_path(project_name)
      end
    end

    def start_command
      "mux start #{project_name}"
    end

    def self.available?
      system('which mux > /dev/null 2>&1')
    end
  end
end
