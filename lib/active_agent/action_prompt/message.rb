# lib/active_agent/action_prompt/message.rb

require "active_model"

module ActiveAgent
  module ActionPrompt
    class Message
      include ActiveModel::API
      include ActiveModel::Attributes

      attribute :content, :string, default: ""
      attribute :requested_actions, default: -> { [] }
      attribute :params, default: -> { {} }
      attribute :role, :string, default: "system"

      VALID_ROLES = %w[system assistant user].freeze

      def initialize(attributes = {})
        super
        validate_role
      end

      def actions_requested?
        requested_actions.any?
      end

      def action_call?
        false
      end

      def to_s
        content.to_s
      end

      def to_h
        {content: content, role: role}
      end

      private

      def validate_role
        unless VALID_ROLES.include?(role)
          raise ArgumentError, "Invalid role: #{role}. Valid roles are: #{VALID_ROLES.join(", ")}"
        end
      end
    end
  end
end
