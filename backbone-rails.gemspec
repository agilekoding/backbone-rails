# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "rails-backbone"
  s.version = "0.5.4"
  s.authors     = ["Ryan Fitzgerald", "Code Brew Studios", "Jairo Vazquez"]
  s.email       = ["ryan@codebrewstudios.com"]
  s.homepage    = "http://github.com/codebrew/backbone-rails"

  s.summary = "Use backbone.js with rails 3.1"
  s.description = "Quickly setup backbone.js for use with rails 3.1. Generators are provided to quickly get started."
  s.files = Dir["lib/**/*"] + Dir["vendor/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency('rails', '~> 3.1')
  s.add_dependency('coffee-script', '~> 2.2')
  s.add_dependency('inherited_resources', '~> 1.3')

  s.require_paths = ['lib']
end
