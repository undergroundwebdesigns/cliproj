module CliProjects
  class Utils
    def self.underscore(string)
      return nil unless string
      string.gsub(/[\s-]/, "_").downcase
    end
  end
end
