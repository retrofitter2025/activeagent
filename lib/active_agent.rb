# lib/active_agent.rb
require "yaml"
require "active_agent/version"
require "active_agent/deprecator"
require "active_agent/action_prompt/prompt_helper"
require "active_support"

module ActiveAgent
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Callbacks
  autoload :ActionPrompt
  autoload :Parameterized
  autoload :Generation
  autoload :GenerationProvider
  autoload :GenerationJob
  autoload :QueuedGeneration

  class << self
    attr_accessor :config

    def configure
      yield self
    end

    def load_configuration(file)
      config_file = YAML.load_file(file, aliases: true)
      env = ENV["RAILS_ENV"] || ENV["ENV"] || "development"
      @config = config_file[env] || config_file
    end
  end
end

autoload :Mime, "action_dispatch/http/mime_type"

ActiveSupport.on_load(:action_view) do
  ActionView::Base.default_formats ||= Mime::SET.symbols
  ActionView::Template.mime_types_implementation = Mime
  ActionView::LookupContext::DetailsKey.clear
end
