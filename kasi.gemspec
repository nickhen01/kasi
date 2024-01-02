# frozen_string_literal: true

require_relative "lib/kasi/version"

Gem::Specification.new do |spec|
  spec.name = "kasi"
  spec.version = Kasi::VERSION
  spec.authors = ["nicolas hennick"]
  spec.email = ["nicolas@digipeakgroup.com"]

  spec.summary = "Field-tested template for your Ruby on Rails projects."
  spec.homepage = "https://github.com/nickhen01/kasi"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"
  #
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.executables << "kasi"
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rails', '~> 7.1'
end
