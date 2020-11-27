# -*- encoding: utf-8 -*-
# stub: progress_bar 1.3.3 ruby lib

Gem::Specification.new do |s|
  s.name = "progress_bar".freeze
  s.version = "1.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Paul Sadauskas".freeze]
  s.date = "2020-11-17"
  s.description = "Give people feedback about long-running tasks without overloading them with information: Use a progress bar, like Curl or Wget!".freeze
  s.email = ["psadauskas@gmail.com".freeze]
  s.homepage = "http://github.com/paul/progress_bar".freeze
  s.licenses = ["WTFPL".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.2.0.rc.2".freeze
  s.summary = "Simple Progress Bar for output to a terminal".freeze

  s.installed_by_version = "3.2.0.rc.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<highline>.freeze, [">= 1.6", "< 3"])
    s.add_runtime_dependency(%q<options>.freeze, ["~> 2.3.0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<reek>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_development_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
    s.add_development_dependency(%q<timecop>.freeze, [">= 0"])
  else
    s.add_dependency(%q<highline>.freeze, [">= 1.6", "< 3"])
    s.add_dependency(%q<options>.freeze, ["~> 2.3.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<reek>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
    s.add_dependency(%q<timecop>.freeze, [">= 0"])
  end
end
