# frozen_string_literal: true

module ActiveAgent
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_configuration
        template "active_agent.yml", "config/active_agent.yml"
      end

      def create_application_agent
        template "application_agent.rb", "app/agents/application_agent.rb"
      end

      def create_agent_layouts
        template "agent.html.erb", "app/views/layouts/agent.html.erb"
        template "agent.text.erb", "app/views/layouts/agent.text.erb"
      end
    end
  end
end
