# lib/active_agent/generation_provider/open_ai_provider.rb

require_relative "base"
require "openai"
require "active_agent/generation_provider/response"

module ActiveAgent
  module GenerationProvider
    class OpenAIProvider < Base
      def initialize(config)
        super
        @api_key = config["api_key"]
        @model_name = config["model"] || "gpt-3.5-turbo"
        @client = OpenAI::Client.new(api_key: @api_key)
      end

      def generate(prompt)
        @prompt = prompt
        parameters = prompt_parameters.merge(model: @model_name)
        # parameters[:instructions] = prompt.instructions.content if prompt.instructions.present?
        if config["stream"]
          parameters[:stream] = stream_proc
        else
          response = @client.chat(parameters: parameters)
        end
        handle_response(response)
      rescue => e
        raise GenerationProviderError, e.message
      end

      private

      def stream_proc
        proc do |chunk, _bytesize|
          new_content = chunk.dig("choices", 0, "delta", "content")
          message = @prompt.messages.find { |message| message.response_number == chunk.dig("choices", 0, "index") }
          message.update(content: message.content + new_content) if new_content
        end
      end

      def handle_response(response)
        message_json = response.dig("choices", 0, "message")
        message_content = message_json["content"]
        message_role = message_json["role"]
        message = ActiveAgent::Message.new(content: message_content, role: message_role)
        ActiveAgent::GenerationProvider::Response.new(message:, raw_response: response)
      end
    end
  end
end
