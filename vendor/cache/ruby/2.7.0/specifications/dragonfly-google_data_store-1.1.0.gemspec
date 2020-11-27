# -*- encoding: utf-8 -*-
# stub: dragonfly-google_data_store 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "dragonfly-google_data_store".freeze
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Raffael Schmid".freeze]
  s.bindir = "exe".freeze
  s.date = "2019-06-20"
  s.email = ["raffael@yux.ch".freeze]
  s.homepage = "https://github.com/wtag/dragonfly-google_data_store".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.0.rc.2".freeze
  s.summary = "A data store for dragonfly using google cloud".freeze

  s.installed_by_version = "3.2.0.rc.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<dragonfly>.freeze, ["~> 1.1"])
    s.add_runtime_dependency(%q<google-cloud-storage>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.14"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
  else
    s.add_dependency(%q<dragonfly>.freeze, ["~> 1.1"])
    s.add_dependency(%q<google-cloud-storage>.freeze, ["~> 1.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.14"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
  end
end
