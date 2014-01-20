module CliProjects::Services::Project
  class Mux < Base

    def setup
      if File.exist? CliProjects::Config.global.mux_path(project_name)
        puts "Not creating a mux file for #{project_name}. File #{CliProjects::Config.global.mux_path(project_name)} already exists."
      else
        puts "Creating a mux profile for #{project_name}"
        template_file = File.open(template_path('mux.erb'), 'r').read
        erb = ERB.new(template_file)
        File.open(CliProjects::Config.global.mux_path(project_name), "w+") do |file|
          file.write(erb.result(binding))
        end
      end
    end

    def tear_down
      if File.exist? CliProjects::Config.global.mux_path(project_name)
        File.delete CliProjects::Config.global.mux_path(project_name)
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
