# frozen_string_literal: true

module ActiveAgent
  module ActionPrompt
    # = Active Agent's Action Prompt \PromptHelper
    #
    # Provides helper methods for ActiveAgent::Base that can be used for easily
    # formatting prompts, accessing agent or prompt instances.
    module PromptHelper
      # Access the mailer instance.
      def agent
        @_controller
      end

      # Access the prompt instance.
      def prompt
        @_prompt
      end
    end
  end
end
