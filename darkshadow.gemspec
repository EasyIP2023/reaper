# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "darkshadow/version"

Gem::Specification.new do |spec|
  spec.name          = "darkshadow"
  spec.version       = DarkShadow::VERSION
  spec.authors       = ["EasyIP2023"]
  spec.email         = ["vdavis2495@gmail.com"]

  spec.summary       = %q{This gem is built to help with rapid exploit development in ruby}
  spec.homepage      = "https://github.com/EasyIP2023/darkshadow"
  spec.license       = "MIT"

  spec.files = Dir.glob("lib/**/*") + Dir['bin/*']
  spec.files += Dir['[A-Z]*']
  spec.files.reject! { |f| f.match(%r{^(test|spec|features)/}) }

  spec.executables << 'darkshadow'

  spec.require_paths = ["lib"]
  spec.metadata["yard.run"] = "yri"

  spec.add_dependency 'bundler', '~> 1.16'
  spec.add_dependency 'rake', '~> 12.0'
  spec.add_dependency 'rex', '~> 0'
  spec.add_dependency 'rex-text', '~> 0'
  spec.add_dependency 'celluloid', '~> 0'
end
