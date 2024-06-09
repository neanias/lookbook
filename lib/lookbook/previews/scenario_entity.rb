module Lookbook
  class ScenarioEntity < Entity
    attr_reader :metadata

    delegate :notes, :notes?, :group, to: :metadata
    delegate :mailer_preview?, to: :@preview_entity

    attr_reader :method_name

    def initialize(code_object, preview_entity, default_priority: nil)
      @preview_entity = preview_entity
      @default_priority = default_priority
      @method_name = code_object.name.to_sym
      @method_source = code_object.source
      @method_parameters = code_object.parameters
      @metadata = PreviewMetadata.new(code_object)
    end

    def id
      @id ||= Utils.id(metadata.fetch(:id, method_name))
    end

    def uuid
      @uuid ||= Utils.hash("#{type}#{Utils.id(preview.id, id)}")
    end

    def name
      @name ||= Utils.name(method_name)
    end

    def label
      metadata.label || super
    end

    def hidden?
      metadata.hidden || super
    end

    def priority
      metadata.priority || super
    end

    def params
      @params ||= metadata.tags(:param).map { ScenarioParam.new(_1, self) }
    end

    def param(name)
      params.find { _1.name == name.to_sym }
    end

    def display_options
      DataObject.new(preview.display_options, metadata.display_options)
    end

    alias_method :url_param, :name

    def lookup_path
      "#{preview_entity.lookup_path}/#{name}"
    end

    def url_path
      inspect_target_path(preview, self)
    end

    def preview_path
      preview_target_path(preview, self)
    end

    def source
      src = if custom_render_template?
        template_source(render_template_path)
      else
        ScenarioEntity.format_source(@method_source)
      end
      src.strip_heredoc.strip.html_safe if src.present?
    end

    def source_language
      if custom_render_template?
        template_language(render_template_path)
      else
        Languages.ruby
      end
    end

    def render_args(request_params: {})
      resolved_params = resolve_request_params(request_params)
      result = call_method(**resolved_params)
      if mailer_preview?
        {
          email: result,
          template: Previews.scenario_template
        }
      else
        result[:template] = template_path if result[:template].nil?
        result.merge(layout: preview_entity.layout)
      end
    end

    # Returns the relative path (from preview_path) to the scenario template if the template exists
    def template_path
      preview_name = preview_class.name.chomp("Preview").underscore
      preview_path =
        Previews.preview_paths.detect do |path|
          Dir["#{path}/#{preview_name}_preview/#{method_name}.html.*"].first
        end

      if preview_path.nil?
        raise Lookbook::Error,
          "A preview template for scenario #{method_name} doesn't exist.\n\n To fix this issue, create a template for the scenario."
      end

      path = Dir["#{preview_path}/#{preview_name}_preview/#{method_name}.html.*"].first
      Pathname.new(path)
        .relative_path_from(Pathname.new(preview_path))
        .to_s
        .sub(/\..*$/, "")
    end

    def template_source(template_path)
      source_path = template_file_path(template_path)
      source_path ? File.read(source_path) : nil
    end

    def template_file_path(template_path)
      return full_template_path(template_path) if respond_to?(:full_template_path, true)

      search_dirs = [*Previews.preview_paths, *Engine.view_paths].uniq
      template_path = "#{template_path.to_s.sub(/\..*$/, "")}.html.*"
      Utils.determine_full_path(template_path, search_dirs)
    end

    def template_language(template_path)
      Languages.guess(template_file_path(template_path), :erb)
    end

    def method_parameters
      pairs = @method_parameters.map { [_1.first.delete_suffix(":").to_sym, _1.last] }
      pairs.to_h.with_indifferent_access
    end

    def mailer_instance(params = {})
      call_method(**resolve_request_params(params)) if mailer_preview?
    end

    def preview = preview_entity

    def to_h
      {
        entity: "scenario",
        id: id,
        uuid: uuid,
        name: name,
        label: label,
        hidden: hidden?,
        lookup_path: lookup_path,
        url_path: url_path,
        preview_path: preview_path
      }
    end

    protected

    attr_reader :preview_entity

    def preview_class
      preview_entity.preview_class
    end

    def call_method(**kwargs)
      preview_class.new.public_send(method_name, **kwargs) || {}
    end

    def render_template_path
      rargs[:template]
    end

    def custom_render_template?
      !render_template_path.in?(Previews.system_templates) && rargs[:type] != :view
    end

    def rargs
      @rargs ||= render_args
    end

    def resolve_request_params(request_params = {})
      method_param_names = method_parameters.keys
      raw_params = request_params.slice(*method_param_names).to_h.symbolize_keys
      raw_params.map do |key, raw_value|
        param_data = param(key)
        [key, param_data ? param_data.cast_value(raw_value) : raw_value]
      end.to_h
    end

    class << self
      # Remove the method definition and `end` keyword to leave just the method body
      def format_source(source)
        source = WhitespaceStripper.call(source)
        lines = source.sub(/^def \w+\s?(\([^)]+\))?/m, "").split("\n")[0..-2]
        (lines.many? ? lines.join("\n") : lines.first)
      end
    end
  end
end
