# lib/active_agent/generation.rb
require "delegate"

module ActiveAgent
  class Generation < Delegator
    def initialize(agent_class, action, *args)
      @agent_class = agent_class
      @action = action
      @args = args
      @processed_agent = nil
      @prompt = nil
    end
    ruby2_keywords(:initialize)

    def __getobj__
      @prompt ||= processed_agent.prompt
    end

    def __setobj__(prompt)
      @prompt = prompt
    end

    def prompt
      __getobj__
    end

    def processed?
      @processed_agent || @prompt
    end

    def generate_now
      processed_agent.handle_exceptions do
        processed_agent.run_callbacks(:generate) do
          @agent_class.perform_generation(prompt)
        end
      end
    end

    def generate_later(options = {})
      if processed?
        raise "You've accessed the prompt before asking to generate it later."
      else
        @agent_class.generation_job.set(options).perform_later(
          @agent_class.name, @action.to_s, args: @args
        )
      end
    end

    private

    def processed_agent
      @processed_agent ||= @agent_class.new.tap do |agent|
        agent.process(@action, *@args)
      end
    end
  end
end
