spec = Gem::Specification.new do |s|
  s.name = 'sweet'
  s.version = '0.0.2'
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "COPYING"]
  s.rdoc_options += ["--quiet", "--line-numbers", "--inline-source", '--title', 'Sweet: The SWT wrapper for JRuby', '--main', 'README.rdoc']
  s.summary = "The SWT wrapper for JRuby"
  s.description = s.summary
  s.author = "Michael Klaus"
  s.email = "Michael.Klaus@gmx.net"
  s.homepage = "http://github.org/QaDeS/sweet"
  s.files = %w(COPYING README.rdoc Rakefile) + Dir["{bin,spec,lib,examples}/**/*"]
  s.require_path = "lib"
  s.bindir = 'bin'
  s.executables << 'sweet'

  s.add_dependency 'zippy'
end
