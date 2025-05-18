require "rails_helper"
# require "./test_helper"
# require "./spec_helper"

describe OllamaAgent do
  describe "#text_prompt" do
    it "renders a text_prompt and generates a response" do
      # VCR.use_cassette("ollama_text_prompt_response") do
        message = "Show me a cat"
        prompt = OllamaAgent.with(message: message).text_prompt
        response = prompt.generate_now

        expect(OllamaAgent.with(message: message).text_prompt.message.content).to eq(message)
        expect(response.prompt.messages.size).to eq(3)
        expect(response.prompt.messages[0].role).to eq(:system)
        expect(response.prompt.messages[1].role).to eq(:user)
        expect(response.prompt.messages[1].content).to eq(message)
        expect(response.prompt.messages[2].role).to eq(:assistant)
      #end
    end

    it "uses the correct model" do
      prompt = OllamaAgent.new.text_prompt
      expect(prompt.options[:model]).to eq("llama3.1:8b")
    end

    it "sets the correct system instructions" do
      prompt = OllamaAgent.new.text_prompt
      system_message = prompt.messages.find { |m| m.role == :system }
      expect(system_message.content).to eq("You're a basic Ollama agent.")
    end
  end
end
