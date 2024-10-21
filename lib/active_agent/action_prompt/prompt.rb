# lib/active_agent/action_prompt/prompt.rb
require_relative "message"

module ActiveAgent
  module ActionPrompt
    class Prompt
      attr_accessor :actions, :content, :instructions, :message, :messages, :params, :mime_version, :charset, :context

      def initialize(attributes = {})
        @actions = attributes.fetch(:actions, [])
        @instructions = attributes.fetch(:instructions, "")
        @message = attributes.fetch(:message, Message.new)
        @messages = attributes.fetch(:messages, [])
        @params = attributes.fetch(:params, {})
        @mime_version = attributes.fetch(:mime_version, "1.0")
        @charset = attributes.fetch(:charset, "UTF-8")
        @context = attributes.fetch(:context, [])
        @content = attributes.fetch(:content, "")

        set_instructions if @instructions.present?
        set_content if @content.present?
        set_message if attributes[:message].is_a?(String)
        set_messages if @messages.any?
      end

      # Generate the prompt as a string (for debugging or sending to the provider)
      def to_s
        @message.to_s
      end

      def to_h
        {
          actions: @actions,
          instructions: @instructions,
          message: @message.to_h,
          messages: @messages.map(&:to_h)
        }
      end

      # Set the content of the prompt (for debugging or sending to the provider)
      def set_content
        @message = Message.new(content: @content, role: :user)
      end

      def set_instructions
        @messages = [Message.new(content: @instructions, role: :system)] + @messages
      end

      def set_message
        @message = Message.new(content: @message, role: :user)
        @messages = [@message] + @messages
      end
    end
  end
end
