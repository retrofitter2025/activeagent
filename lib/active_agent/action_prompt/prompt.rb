# lib/active_agent/action_prompt/prompt.rb
require_relative "message"

module ActiveAgent
  module ActionPrompt
    class Prompt
      attr_accessor :actions, :content, :content_type, :instructions, :message, :messages, :params, :mime_version, :charset, :context

      def initialize(attributes = {})
        @actions = attributes.fetch(:actions, [])
        @instructions = attributes.fetch(:instructions, "")
        @content = attributes.fetch(:content, "")
        @content_type = attributes.fetch(:content_type, "text/plain")
        @message = attributes.fetch(:message, Message.new)
        @messages = attributes.fetch(:messages, [])
        @params = attributes.fetch(:params, {})
        @mime_version = attributes.fetch(:mime_version, "1.0")
        @charset = attributes.fetch(:charset, "UTF-8")
        @context = attributes.fetch(:context, [])
        @headers = attributes.fetch(:headers, {})
        @parts = attributes.fetch(:parts, [])

        set_message if attributes[:message].is_a?(String) || @content.is_a?(String) && @message.content.blank?
        set_messages if @messages.any? || @instructions.present?
      end

      # Generate the prompt as a string (for debugging or sending to the provider)
      def to_s
        @message.to_s
      end

      def add_part(part)
        message = Message.new(content: part[:body], role: :assistant)
        prompt_part = self.class.new(message: message, content: message.content, content_type: part[:content_type], chartset: part[:charset])

        @message = message if @content_type == part[:content_type] && @message.content.blank?

        @parts << prompt_part
      end

      def multipart?
        @parts.any?
      end

      def to_h
        {
          actions: @actions,
          instructions: @instructions,
          message: @message.to_h,
          messages: @messages.map(&:to_h),
          headers: @headers,
          context: @context
        }
      end

      def headers(headers = {})
        @headers.merge!(headers)
      end

      def set_messages
        @messages = [Message.new(content: @instructions, role: :system)] + @messages
      end

      def set_message
        if @content.is_a?(String) && @message.content.blank?
          @message = Message.new(content: @content, role: :user)
        elsif !@message.content.blank?
          @message = Message.new(content: @message, role: :user)
        end
        @messages = [@message] + @messages
      end
    end
  end
end
