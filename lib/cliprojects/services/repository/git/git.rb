module CliProjects::Services::Repository
  class Git < Base
    def setup
      if options[:git_repo]
        puts "Attempting to clone #{options[:git_repo]} into #{repository_path}"
        `git clone '#{options[:git_repo]}' '#{repository_path}'`
      else
        puts "Initializing a new git repo in #{repository_path}"
        FileUtils.mkdir_p(repository_path)
        `git init '#{repository_path}'`
      end
    end
  end
end
