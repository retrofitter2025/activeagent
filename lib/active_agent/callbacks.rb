# frozen_string_literal: true

require "active_support/concern"

module ActiveAgent
  module Callbacks
    extend ActiveSupport::Concern

    included do
      include ActiveSupport::Callbacks
      define_callbacks :generate
      define_callbacks :process_action
    end

    module ClassMethods
      def before_generate(*methods)
        set_callback :generate, :before, *methods
      end

      def after_generate(*methods)
        set_callback :generate, :after, *methods
      end

      def around_generate(*methods)
        set_callback :generate, :around, *methods
      end

      def before_action(*filters, &)
        set_callback(:process_action, :before, *filters, &)
      end

      def after_action(*filters, &)
        set_callback(:process_action, :after, *filters, &)
      end

      def around_action(*filters, &)
        set_callback(:process_action, :around, *filters, &)
      end
    end

    def process(action, *args)
      run_callbacks :process_action do
        public_send(action, *args)
      end
    end
  end
end
