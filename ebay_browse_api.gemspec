require_relative 'lib/ebay_browse_api/version'

Gem::Specification.new do |spec|
  spec.name          = "ebay_browse_api"
  spec.version       = EbayBrowseApi::VERSION
  spec.authors       = ["Ohad Dahan"]
  spec.email         = ["ohaddahan@gmail.com"]

  spec.summary       = %q{Basic wrapper for https://developer.ebay.com/api-docs/buy/static/api-browse.html}
  spec.description   = %q{Basic wrapper for https://developer.ebay.com/api-docs/buy/static/api-browse.html}
  spec.homepage      = "https://github.com/ohaddahan/ebay_browse_api"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ohaddahan/ebay_browse_api"
  spec.metadata["changelog_uri"] = "https://github.com/ohaddahan/ebay_browse_api"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_dependency "typhoeus", "~> 1.4.0"
  spec.add_dependency "oj", "~> 3.10.6"
  spec.add_dependency "date", "~> 3.0.0"
end
