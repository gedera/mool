lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mool/version'

Gem::Specification.new do |gem|
  gem.name          = "mool"
  gem.version       = Mool::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ["g.edera", "eserdio"]
  gem.email         = ["gab.edera@gmail.com"]
  gem.description   = "Get operative system information: Disk, Memory, Cpu, Load-average, Processes"
  gem.summary       = "Get operative system information (Linux)"
  gem.homepage      = "https://github.com/gedera/mool"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
