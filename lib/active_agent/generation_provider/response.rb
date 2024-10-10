# frozen_string_literal: true

module ActiveAgent
  module GenerationProvider
    class Response
      attr_reader :raw_response

      def initialize(message:, raw_response: nil)
        @raw_response = raw_response
      end

      def message
        raise NotImplementedError, "Subclasses must implement the message method"
      end
    end
  end
end
