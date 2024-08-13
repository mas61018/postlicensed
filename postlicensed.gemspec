# frozen_string_literal: true

require_relative "lib/postlicensed/program_name"
require_relative "lib/postlicensed/version"

Gem::Specification.new do |spec|
  spec.name          = Postlicensed::PROGRAM_NAME
  spec.version       = Postlicensed::VERSION
  spec.authors       = ["mas61018"]
  spec.email         = ["mas61018@users.noreply.github.com"]

  spec.summary       = "A tool used after Licensed for niche purposes"
  # spec.description   = "TODO: Write a longer description or delete this line."
  spec.homepage      = "https://github.com/mas61018/postlicensed"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1.6")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "csv", "~> 3.3"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
