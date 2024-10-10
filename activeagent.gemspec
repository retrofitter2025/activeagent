Gem::Specification.new do |s|
  s.name = "activeagent"
  s.version = "0.0.0"
  s.summary = "A simple way to perform long running LLM background jobs and streaming responses"
  s.description = "A simple way to perform long running LLM background jobs and streaming responses"
  s.authors = ["Justin Bowen"]
  s.email = "jusbowen@gmail.com"
  s.files = ["lib/active_agent.rb"]
  s.homepage =
    "https://rubygems.org/gems/activeagent"
  s.license = "MIT"
  Gem::Specification.new do |s|
    s.name = "activeagent"
    s.version = "0.0.0"
    s.summary = "A simple way to perform long running LLM background jobs and streaming responses"
    s.description = "A simple way to perform long running LLM background jobs and streaming responses"
    s.authors = ["Justin Bowen"]
    s.email = "jusbowen@gmail.com"
    s.files = ["lib/active_agent.rb"]
    s.homepage = "https://rubygems.org/gems/activeagent"
    s.license = "MIT"

    # Add dependencies
    s.add_dependency "ruby-openai", "~> 7.1.0"
    s.add_dependency "anthropic", "~> 0.3.0"
    s.add_dependency "actionpack", ">= 7.2.1"
    s.add_dependency "actionview", ">= 7.2.1"
    s.add_dependency "activesupport", ">= 7.2.1"
  end
end
