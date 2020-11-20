# -*- encoding: utf-8 -*-
# stub: taglib-ruby 0.7.1 ruby lib
# stub: ext/taglib_base/extconf.rb ext/taglib_mpeg/extconf.rb ext/taglib_id3v1/extconf.rb ext/taglib_id3v2/extconf.rb ext/taglib_ogg/extconf.rb ext/taglib_vorbis/extconf.rb ext/taglib_flac/extconf.rb ext/taglib_mp4/extconf.rb ext/taglib_aiff/extconf.rb ext/taglib_wav/extconf.rb

Gem::Specification.new do |s|
  s.name = "taglib-ruby".freeze
  s.version = "0.7.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Robin Stocker".freeze, "Jacob Vosmaer".freeze, "Thomas Chevereau".freeze]
  s.date = "2015-12-28"
  s.description = "Ruby interface for the taglib C++ library, for reading and writing\nmeta-data (tags) of many audio formats.\n\nIn contrast to other libraries, this one wraps the C++ API using SWIG,\nnot only the minimal C API. This means that all tags can be accessed.\n".freeze
  s.email = ["robin@nibor.org".freeze]
  s.extensions = ["ext/taglib_base/extconf.rb".freeze, "ext/taglib_mpeg/extconf.rb".freeze, "ext/taglib_id3v1/extconf.rb".freeze, "ext/taglib_id3v2/extconf.rb".freeze, "ext/taglib_ogg/extconf.rb".freeze, "ext/taglib_vorbis/extconf.rb".freeze, "ext/taglib_flac/extconf.rb".freeze, "ext/taglib_mp4/extconf.rb".freeze, "ext/taglib_aiff/extconf.rb".freeze, "ext/taglib_wav/extconf.rb".freeze]
  s.extra_rdoc_files = ["CHANGES.md".freeze, "LICENSE.txt".freeze, "README.md".freeze]
  s.files = ["CHANGES.md".freeze, "LICENSE.txt".freeze, "README.md".freeze, "ext/taglib_aiff/extconf.rb".freeze, "ext/taglib_base/extconf.rb".freeze, "ext/taglib_flac/extconf.rb".freeze, "ext/taglib_id3v1/extconf.rb".freeze, "ext/taglib_id3v2/extconf.rb".freeze, "ext/taglib_mp4/extconf.rb".freeze, "ext/taglib_mpeg/extconf.rb".freeze, "ext/taglib_ogg/extconf.rb".freeze, "ext/taglib_vorbis/extconf.rb".freeze, "ext/taglib_wav/extconf.rb".freeze]
  s.homepage = "http://robinst.github.io/taglib-ruby/".freeze
  s.licenses = ["MIT".freeze]
  s.requirements = ["taglib (libtag1-dev in Debian/Ubuntu, taglib-devel in Fedora/RHEL)".freeze]
  s.rubygems_version = "3.2.0.rc.2".freeze
  s.summary = "Ruby interface for the taglib C++ library".freeze

  s.installed_by_version = "3.2.0.rc.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.2"])
    s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 0.9"])
    s.add_development_dependency(%q<shoulda-context>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<yard>.freeze, ["~> 0.7"])
    s.add_development_dependency(%q<kramdown>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<test-unit>.freeze, ["~> 3.1"])
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.2"])
    s.add_dependency(%q<rake-compiler>.freeze, ["~> 0.9"])
    s.add_dependency(%q<shoulda-context>.freeze, ["~> 1.0"])
    s.add_dependency(%q<yard>.freeze, ["~> 0.7"])
    s.add_dependency(%q<kramdown>.freeze, ["~> 1.0"])
    s.add_dependency(%q<test-unit>.freeze, ["~> 3.1"])
  end
end
