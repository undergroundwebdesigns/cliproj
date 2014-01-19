module CliProjects::Services
  class Base

    class << self

      def services
        @services.select {|service| service.available? }
      end

      def inherited(subclass)
        @services ||= []
        @services << subclass
      end
    end

    attr_reader :options

    def initialize(obj_name, options = {})
      @options = options
    end

    def template_path (file_name)
      @template_path ||= {}
      @template_path[file_name] ||= begin
        custom_path = override_template_path(file_name)
        custom_path && File.exist?(custom_path) ? custom_path : default_template_path(file_name)
      end
    end

    def override_template_path(file_name)
      class_parts = self.class.name.split("::").map{ |part| part.downcase }
      CliProjects::Config.opts[:template_overrides_path] ? File.join(CliProjects::Config.opts[:template_overrides_path], *class_parts, file_name) : nil
    end

    def default_template_path(file_name)
      class_parts = self.class.name.split("::").map{ |part| part.downcase }[-2, 2]
      File.join(File.expand_path(File.dirname(File.dirname(__FILE__))), *class_parts, 'templates', file_name)
    end

    def setup
      raise "Not implemented!"
    end

    def tear_down
    end

    def start_command
    end

    # Can be over-ridden in subclasses to dynamically determine
    # whether the initializer should be considered available.
    def self.available?
      true
    end
  end
end
