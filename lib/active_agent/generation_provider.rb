# frozen_string_literal: true

module ActiveAgent
  module GenerationProvider
    def self.for(provider_name, **options)
      config = ActiveAgent.config[provider_name.to_s] || ActiveAgent.config[ENV["RAILS_ENV"]][provider_name.to_s]
      raise "Configuration not found for provider: #{provider_name}" unless config

      config.merge!(options)
      configure_provider(config)
    end

    def self.configure_provider(config)
      require "active_agent/generation_provider/#{config["service"].underscore}_provider"
      ActiveAgent::GenerationProvider.const_get("#{config["service"].camelize}Provider").new(config)
    rescue LoadError
      raise "Missing generation provider for #{config["service"].inspect}"
    end
  end
end
