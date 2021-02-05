# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "bouncer"
  spec.version       = '1.2.6'
  spec.authors       = ["Adam Carlile", "Serafeim Maroulis"]
  spec.email         = ["github@adamcarlile.com", "serafeim@hey.com"]
  spec.summary       = %q{SSO Bouncer}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("omniauth", ["~> 1.0"])
  spec.add_runtime_dependency('omniauth-oauth2', ['~> 1.0'])
  spec.add_runtime_dependency('omniauth_openid_connect', ["0.3.3"])
  spec.add_runtime_dependency("oauth2", ["~> 1.0"])
  spec.add_runtime_dependency("virtus")
  spec.add_runtime_dependency('warden')
  spec.add_runtime_dependency('activemodel')
  spec.add_runtime_dependency('warden_omniauth')
  spec.add_runtime_dependency("sinatra")
  spec.add_runtime_dependency("rack")
  spec.add_runtime_dependency("faraday")
  spec.add_runtime_dependency("jwt")

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fabrication"
  spec.add_development_dependency "webmock"
end
