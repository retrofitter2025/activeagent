# lib/active_agent/action_prompt/prompt.rb
require "active_model"
require_relative "message"

module ActiveAgent
  module ActionPrompt
    class Prompt
      include ActiveModel::API
      include ActiveModel::Attributes

      attribute :actions, default: -> { [] }
      attribute :instructions, :string, default: ""
      attribute :message, default: -> { Message.new }
      attribute :messages, default: -> { [] }
      attribute :params, default: -> { {} }

      def initialize(attributes = {})
        super
        set_instructions if instructions.present?
        set_message if attributes[:message].is_a?(String)
        set_messages if messages.any?
      end

      # Generate the prompt as a string (for debugging or sending to the provider)
      def to_s
        message.to_s
      end

      def to_h
        {
          actions: actions,
          instructions: instructions,
          message: message.to_h,
          messages: messages.map(&:to_h)
        }
      end

      private

      def set_instructions
        self.instructions = Message.new(content: instructions, role: :system)
      end

      def set_message
        self.message = Message.new(content: message, role: :user)
      end

      def set_messages
        self.messages = messages.map do |msg|
          msg.is_a?(Message) ? msg : Message.new(content: msg, role: :user)
        end
      end
    end
  end
end
