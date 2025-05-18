require "openai"
require "active_agent/action_prompt/action"
require_relative "base"
require_relative "response"

module ActiveAgent
  module GenerationProvider
    class OpenAIProvider < Base
      def initialize(config)
        super
        @api_key = config["api_key"]
        @model_name = config["model"] || "gpt-4o-mini"
        @client = OpenAI::Client.new(access_token: @api_key, log_errors: true)
      end

      def generate(prompt)
        @prompt = prompt

        chat_prompt(parameters: prompt_parameters)
      rescue => e
        raise GenerationProviderError, e.message
      end

      def embed(prompt)
        @prompt = prompt

        embeddings_prompt(parameters: embeddings_parameters)
      rescue => e
        raise GenerationProviderError, e.message
      end

      private

      def provider_stream
        agent_stream = prompt.options[:stream]
        message = ActiveAgent::ActionPrompt::Message.new(content: "", role: :assistant)

        @response = ActiveAgent::GenerationProvider::Response.new(prompt: prompt, message: message)
        proc do |chunk, bytesize|
          choices = chunk["choices"]&.first
          delta = choices && choices["delta"]
          new_content = delta && delta["content"]

          if new_content && !new_content.blank?
            message.content += new_content

            agent_stream.call(message, new_content, false) do |message, new_content|
              yield message, new_content if block_given?
            end
          elsif delta && delta["tool_calls"] && !delta["tool_calls"].empty?
            message = handle_message(delta)
            prompt.messages << message
            @response =
              ActiveAgent::GenerationProvider::Response.new(prompt: prompt, message:message)
          end

          agent_stream.call(message, nil, true) do |message|
            yield message, nil if block_given?
          end
        end
      end

      def prompt_parameters(model: @prompt.options[:model] || @model_name, messages: @prompt.messages, temperature: @config["temperature"] || 0.7, tools: @prompt.actions)
        {
          model: model,
          messages: provider_messages(messages),
          temperature: temperature,
          tools: tools.presence
        }
      end

      def provider_messages(messages)
        messages.map do |message|
          provider_message = {
            role: message.role,
            tool_call_id: message.action_id.presence,
            content: message.content,
            type: message.content_type,
            charset: message.charset
          }.compact

          if message.content_type == "image_url"
            provider_message[:image_url] = { url: message.content }
          end
          provider_message
        end
      end

      def chat_response(response)
        return @response if prompt.options[:stream]

        choices = response["choices"]&.first
        message_json = choices && choices["message"]

        message = handle_message(message_json)

        update_context(prompt: prompt, message: message, response: response)

        @response = ActiveAgent::GenerationProvider::Response.new(prompt: prompt, message: message, raw_response: response)
      end

      def handle_message(message_json)
        return nil unless message_json

        ActiveAgent::ActionPrompt::Message.new(
          content: message_json["content"],
          role: message_json["role"]&.to_sym,
          action_requested: message_json["finish_reason"] == "tool_calls",
          requested_actions: handle_actions(message_json["tool_calls"])
        )
      end

      def handle_actions(tool_calls)
        return [] if tool_calls.nil? || tool_calls.empty?

        tool_calls.map do |tool_call|
          next if tool_call["function"].nil? || tool_call["function"]["name"].blank?
          args = tool_call["function"]["arguments"].blank? ? nil : JSON.parse(tool_call["function"]["arguments"], { symbolize_names: true })

          ActiveAgent::ActionPrompt::Action.new(
            id: tool_call["id"],
            name: tool_call["function"]["name"],
            params: args
          )
        end.compact
      end

      def chat_prompt(parameters: prompt_parameters)
        parameters[:stream] = provider_stream if prompt.options[:stream] || config["stream"]
        chat_response(@client.chat(parameters: parameters))
      end

      def embeddings_parameters(input: prompt.message.content, model: "text-embedding-3-large")
        {
          model: model,
          input: input
        }
      end

      def embeddings_response(response)
        data = response["data"]&.first
        embedding = data && data["embedding"]
        message = ActiveAgent::ActionPrompt::Message.new(content: embedding, role: "assistant")

        @response = ActiveAgent::GenerationProvider::Response.new(prompt: prompt, message: message, raw_response: response)
      end

      def embeddings_prompt(parameters:)
        embeddings_response(@client.embeddings(parameters: embeddings_parameters))
      end
    end
  end
end
