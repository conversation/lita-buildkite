Gem::Specification.new do |spec|
  spec.name = "lita-buildkite"
  spec.version = "0.1.0"
  spec.summary = "Lita handler for interacting with buildkite.com, a continuous integration provider"
  spec.description = "Lita handler for interacting with buildkite.com, a continuous integration provider"
  spec.license = "MIT"
  spec.files =  Dir.glob("{lib}/**/**/*")
  spec.extra_rdoc_files = %w{README.md MIT-LICENSE }
  spec.authors = ["James Healy"]
  spec.email   = ["james.healy@theconversation.edu.au"]
  spec.homepage = "http://github.com/conversation/lita-buildkite"
  spec.required_ruby_version = ">=1.9.3"
  spec.metadata = { "lita_plugin_type" => "handler" }

  spec.add_development_dependency("rake")
  spec.add_development_dependency("rspec", "~> 3.4")
  spec.add_development_dependency("pry")
  spec.add_development_dependency("rdoc")

  spec.add_dependency("lita")
end
