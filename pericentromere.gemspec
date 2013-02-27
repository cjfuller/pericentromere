Gem::Specification.new do |s|

  s.name        = 'pericentromere'
  s.version     = '0.0.1'
  s.date        = '2013-02-26'
  s.summary     = "Analysis of pericentromeric heterochromatin"
  s.description = "Analysis of localization of heterochromatin proteins, marks, etc. to regions near the centromere."
  s.authors     = ["Colin J. Fuller"]
  s.email       = 'cjfuller@gmail.com'
  s.homepage    = 'https://bitbucket.org/cjfuller/pericentromere'
  s.add_runtime_dependency 'rimageanalysistools'
  s.add_runtime_dependency 'find_beads'
  s.add_runtime_dependency 'trollop'
  s.files       = Dir["lib/**/*.rb", 'bin/**/*']
  s.executables << 'pericentromere'
  s.platform    = 'java'
  s.require_paths << 'extlib'
  s.license     = 'MIT'
  s.requirements = 'jruby'

end
