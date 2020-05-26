Gem::Specification.new do |spec|
  spec.name          = "lita-victorops"
  spec.version       = "0.1.0"
  spec.authors       = ["Jurnell Cockhren"]
  spec.email         = ["jurnell@civichacker.com"]
  spec.description   = "Add a description"
  spec.summary       = "Add a summary"
  spec.homepage      = "https://civichacker.com"
  spec.license       = "Mozilla Public License 2.0"
  spec.metadata      = { "lita_plugin_type" => "adapter" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.7"
  spec.add_runtime_dependency "eventmachine"
  spec.add_runtime_dependency "websocket-eventmachine-client"
  spec.add_runtime_dependency "em-eventsource", "~> 0.3.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
