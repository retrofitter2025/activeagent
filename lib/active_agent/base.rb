# lib/active_agent/base.rb
require "abstract_controller"
require "active_support/all"
require "action_view"
require "active_agent/rescuable"
require "active_agent/action_prompt/collector"
require "active_agent/action_prompt/prompt"
require "active_agent/action_prompt/message"

module ActiveAgent
  class Base < AbstractController::Base
    include Callbacks
    include QueuedGeneration
    include ActionPrompt
    include Rescuable
    include GenerationProvider
    include Parameterized

    abstract!

    include AbstractController::Rendering

    include AbstractController::Logger
    include AbstractController::Helpers
    include AbstractController::Translation
    include AbstractController::AssetPaths
    include AbstractController::Callbacks
    include AbstractController::Caching

    include ActionView::Layouts

    PROTECTED_IVARS = AbstractController::Rendering::DEFAULT_PROTECTED_INSTANCE_VARIABLES + [:@_action_has_layout]

    helper ActiveAgent::ActionPrompt::PromptHelper

    class_attribute :options

    attr_internal :_prompt

    class_attribute :default_params, default: {
      mime_version: "1.0",
      charset: "UTF-8",
      content_type: "text/plain",
      parts_order: ["text/plain", "text/enriched", "text/html"]
    }.freeze

    class << self
      def prompt(headers = {}, &)
        new.prompt(headers, &)
      end

      # Returns the name of the current agent. This method is also being used as a path for a view lookup.
      # If this is an anonymous agent, this method will return +anonymous+ instead.
      def agent_name
        @agent_name ||= anonymous? ? "anonymous" : name.underscore
      end
      # Allows to set the name of current agent.
      attr_writer :agent_name
      alias_method :controller_path, :agent_name

      # Define how the agent should generate content
      def generate_with(provider, **options)
        self.generation_provider = provider
        self.options = options
      end

      # Sets the defaults through app configuration:
      #
      #     config.active_agent.default(from: "no-reply@example.org")
      #
      # Aliased by ::default_options=
      def default(value = nil)
        self.default_params = default_params.merge(value).freeze if value
        default_params
      end
      # Allows to set defaults through app configuration:
      #
      #    config.active_agent.default_options = { from: "no-reply@example.org" }
      alias_method :default_options=, :default

      # Handle action methods dynamically
      def method_missing(method_name, *, &block)
        if action_methods.include?(method_name.to_s)
          ActiveAgent::Generation.new(self, method_name, *)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        action_methods.include?(method_name.to_s) || super
      end

      # Collect all action methods defined in the agent class, excluding inherited methods
      # def action_methods
      #   @action_methods ||= public_instance_methods(false).map(&:to_s) - base_instance_methods
      # end

      # Base instance methods to exclude from action methods
      def base_instance_methods
        ActiveAgent::Base.public_instance_methods(false).map(&:to_s)
      end
    end

    # Initialize instance variables
    def initialize
      super
      @_prompt_was_called = false
      @_prompt = ActiveAgent::ActionPrompt::Prompt.new
    end

    def process(method_name, *args) # :nodoc:
      payload = {
        agent: self.class.name,
        action: method_name,
        args: args
      }

      ActiveSupport::Notifications.instrument("process.active_agent", payload) do
        super
        @_prompt = Prompt.new unless @_prompt_was_called
      end
    end
    ruby2_keywords(:process)

    def prompt(headers = {}, &block)
      return @_prompt if @_prompt_was_called && headers.blank? && !block

      headers = apply_defaults(headers)

      @_prompt = ActiveAgent::ActionPrompt::Prompt.new

      assign_headers_to_prompt(@_prompt, headers)

      responses = collect_responses(headers, &block)

      @_prompt_was_called = true

      create_parts_from_responses(@_prompt, responses)

      @_prompt
    end

    # Returns the name of the agent object.
    def agent_name
      self.class.agent_name
    end

    # Accessors for params and context
    attr_accessor :message
    attr_reader :content
    attr_reader :context

    # Render the default instructions
    def instructions
      render template: "#{self.class.name.underscore}/instructions", formats: [:text]
    end

    # Generate a response from the provider
    def generate
      generation_provider.generate(@_prompt)
    end

    # Handle exceptions
    def handle_exceptions
      yield
    rescue => e
      self.class.handle_exception(e)
    end

    def headers(args = nil)
      if args
        @_prompt.headers(args)
      else
        @_prompt
      end
    end

    private

    def apply_defaults(headers)
      default_values = self.class.default.except(*headers.keys).transform_values do |value|
        compute_default(value)
      end

      headers_with_defaults = headers.reverse_merge(default_values)
      headers_with_defaults[:subject] ||= default_i18n_subject
      headers_with_defaults
    end

    def default_i18n_subject(interpolations = {}) # :doc:
      agent_scope = self.class.agent_name.tr("/", ".")
      I18n.t(:subject, **interpolations.merge(scope: [agent_scope, agent_name], default: agent_name.humanize))
    end

    def compute_default(value)
      return value unless value.is_a?(Proc)

      if value.arity == 1
        instance_exec(self, &value)
      else
        instance_exec(&value)
      end
    end

    def assign_headers_to_prompt(prompt, headers)
      binding.irb
      assignable = headers.except(:parts_order, :content, :content_type, :body, :subject, :template_name, :template_path)
      assignable.each { |k, v| prompt.send(:"#{k}=", v) }
    end

    def collect_responses(headers, &block)
      if block
        collect_responses_from_block(headers, &block)
      elsif headers[:body]
        collect_responses_from_text(headers)
      else
        collect_responses_from_templates(headers)
      end
    end

    def collect_responses_from_block(headers, &block)
      binding.irb
      templates_name = headers[:template_name] || action_name
      collector = ::ActionPrompt::Collector.new(lookup_context) { render(templates_name) }
      yield(collector)
      collector.responses
    end

    def collect_responses_from_text(headers)
      [{
        body: headers.delete(:body),
        content_type: headers[:content_type] || "text/plain"
      }]
    end

    def collect_responses_from_templates(headers)
      binding.irb
      templates_path = headers[:template_path] || self.class.agent_name
      templates_name = headers[:template_name] || action_name
      each_template(Array(templates_path), templates_name).map do |template|
        format = template.format || formats.first
        {
          body: render(template: template, formats: [format]),
          content_type: Mime[format].to_s
        }
      end
    end

    def each_template(paths, name, &)
      templates = lookup_context.find_all(name, paths)
      if templates.empty?
        binding.irb
        raise ActionView::MissingTemplate.new(paths, name, paths, false, "agent")
      else
        templates.uniq(&:format).each(&)
      end
    end

    def create_parts_from_responses(prompt, responses)
      responses.each do |response|
        prompt.message = Message.new(content: response[:body])
      end
    end
  end
end
