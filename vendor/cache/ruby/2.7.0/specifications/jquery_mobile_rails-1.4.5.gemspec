# -*- encoding: utf-8 -*-
# stub: jquery_mobile_rails 1.4.5 ruby lib

Gem::Specification.new do |s|
  s.name = "jquery_mobile_rails".freeze
  s.version = "1.4.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tiago Scolari".freeze, "Dylan Markow".freeze]
  s.date = "2014-11-03"
  s.description = "JQuery Mobile files for Rails' assets pipeline".freeze
  s.email = ["tscolari@gmail.com".freeze, "dylan@dylanmarkow.com".freeze]
  s.homepage = "https://github.com/tscolari/jquery-mobile-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.0.rc.2".freeze
  s.summary = "JQuery Mobile files for Rails.".freeze

  s.installed_by_version = "3.2.0.rc.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<railties>.freeze, [">= 3.1.0"])
    s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
  else
    s.add_dependency(%q<railties>.freeze, [">= 3.1.0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
  end
end
