class OllamaAgent < ActiveAgent::Base
  layout "agent"
  generate_with :ollama, model: "llama3.1:8b", instructions: "You're a basic Ollama agent."

  def text_prompt
    prompt(stream: params[:stream], message: params[:message], context_id: params[:context_id]) { |format| format.text { render plain: params[:message] } }
  end
end
