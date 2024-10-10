# lib/active_agent/generation_provider/base.rb

module ActiveAgent
  module GenerationProvider
    class Base
      attr_reader :config, :prompt

      def initialize(config)
        @config = config
        @prompt = nil
      end

      def generate(prompt)
        @prompt = prompt
        raise NotImplementedError, "Subclasses must implement the 'generate' method"
      end

      protected

      def prompt_parameters
        {
          messages: prompt_messages,
          temperature: @config["temperature"] || 0.7
        }
      end

      def prompt_messages
        messages = []
        if @prompt.instructions.present?
          system_message = @prompt.instructions.to_h
          messages << system_message
        end

        messages.concat(@prompt.messages.map(&:to_h)) if @prompt.messages.present?

        if @prompt.message.present?
          prompt_message = @prompt.message.to_h
          messages << prompt_message
        end

        messages
      end

      def generation_provider_response(response)
        message = extract_message_from_response(response)
        ActiveAgent::GenerationProvider::Response.new(response: message)
      end

      def extract_message_from_response(response)
        raise NotImplementedError, "Subclasses must implement the 'extract_message_from_response' method"
      end

      def handle_error(error)
        Rails.logger.error "#{self.class.name} Error: #{error.message}"
        raise error
      end
    end
  end
end
