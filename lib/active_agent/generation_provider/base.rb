# lib/active_agent/generation_provider/base.rb

module ActiveAgent
  module GenerationProvider
    class Base
      attr_reader :config, :prompt

      def initialize(config)
        @config = config
        @prompt = nil
        @response = nil
      end

      def generate(prompt)
        raise NotImplementedError, "Subclasses must implement the 'generate' method"
      end

      protected

      def prompt_parameters
        {
          messages: @prompt.messages,
          temperature: @config["temperature"] || 0.7
        }
      end
    end
  end
end
