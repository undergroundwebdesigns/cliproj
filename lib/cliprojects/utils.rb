module CliProjects
  class Utils
    def self.underscore(string)
      string.gsub(/[\s-]/, "_").downcase
    end
  end
end
