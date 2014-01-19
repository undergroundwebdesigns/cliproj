module CliProjects::Services
  class Git < Base
    def init
      if options[:git_repo]
        puts "Attempting to clone #{options[:git_repo]} into #{code_path}"
        `git clone '#{options[:git_repo]}' '#{code_path}'`
      else
        repo_path = CliProjects::Config.repo_path(project_name, repo_name)
        puts "Initializing a new git repo in #{repo_path}"
        FileUtils.mkdir_p(repo_path)
        `git init '#{repo_path}'`
      end
    end
  end
end
