module CliProjects::Services
  class Git < Base
    def init
      if options[:git_repo]
        puts "Attempting to clone #{options[:git_repo]} into #{code_path}"
        `git clone '#{options[:git_repo]}' '#{code_path}'`
      else
        puts "Initializing a new git repo in #{code_path}"
        `git init '#{code_path}'`
      end
    end
  end
end
