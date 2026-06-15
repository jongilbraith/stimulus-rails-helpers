Gem::Specification.new do |s|
  s.name          = "stimulus-rails-helpers"
  s.version       = "0.0.1"
  s.summary       = "Some helpers to help tame the task of wrangling Stimulus' data attributes."
  s.authors       = ["Jon Gilbraith"]
  s.files         = ["stimulus_rails_helpers.gemspec"] + Dir["lib/**/*.rb"]
  s.metadata      = { "source_code_uri" => "https://github.com/jongilbraith/stimulus-rails-helpers" }
  s.license       = "MIT"
  s.homepage      = "https://github.com/jongilbraith/stimulus-rails-helpers"

  s.add_runtime_dependency "actionview"
  s.add_runtime_dependency "activesupport"
end
