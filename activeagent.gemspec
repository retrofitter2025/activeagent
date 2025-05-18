require_relative "lib/active_agent/version"

Gem::Specification.new do |spec|
  spec.name = "activeagent"
  spec.version = ActiveAgent::VERSION
  spec.summary = "Rails AI Agents Framework"
  spec.description = "The only agent-oriented AI framework designed for Rails, where Agents are Controllers. Build AI features with less complexity using the MVC conventions you love."
  spec.authors = [ "Justin Bowen" ]
  spec.email = "jusbowen@gmail.com"
  spec.files = Dir["CHANGELOG.md", "README.rdoc", "MIT-LICENSE", "lib/**/*"]
  spec.require_paths = "lib"
  spec.homepage = "https://activeagents.ai"
  spec.license = "MIT"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/activeagents/activeagent/issues",
    "documentation_uri" => "https://github.com/activeagents/activeagent",
    "source_code_uri" => "https://github.com/activeagents/activeagent",
    "rubygems_mfa_required" => "true"
  }
  # Add dependencies
  spec.required_ruby_version = ">= 2.6.10", "< 2.7"
  spec.add_dependency "actionpack", "~> 6.0.6.1"
  spec.add_dependency "actionview", "~> 6.0.6.1"
  spec.add_dependency "activesupport", "~> 6.0.6.1"
  spec.add_dependency "activemodel", "~> 6.0.6.1"
  spec.add_dependency "activejob", "~> 6.0.6.1"
  spec.add_dependency "rails", "~> 6.0.6.1"
end
