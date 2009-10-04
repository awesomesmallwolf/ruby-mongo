# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mongoid}
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Durran Jordan"]
  s.date = %q{2009-10-03}
  s.email = %q{durran@gmail.com}
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = [
    ".gitignore",
     "MIT_LICENSE",
     "README.textile",
     "Rakefile",
     "VERSION",
     "lib/mongoid.rb",
     "lib/mongoid/associations.rb",
     "lib/mongoid/associations/belongs_to_association.rb",
     "lib/mongoid/associations/decorator.rb",
     "lib/mongoid/associations/factory.rb",
     "lib/mongoid/associations/has_many_association.rb",
     "lib/mongoid/associations/has_one_association.rb",
     "lib/mongoid/document.rb",
     "lib/mongoid/extensions.rb",
     "lib/mongoid/extensions/array/conversions.rb",
     "lib/mongoid/extensions/object/conversions.rb",
     "mongoid.gemspec",
     "spec/integration/mongoid/document_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/unit/mongoid/associations/belongs_to_association_spec.rb",
     "spec/unit/mongoid/associations/decorator_spec.rb",
     "spec/unit/mongoid/associations/factory_spec.rb",
     "spec/unit/mongoid/associations/has_many_association_spec.rb",
     "spec/unit/mongoid/associations/has_one_association_spec.rb",
     "spec/unit/mongoid/document_spec.rb",
     "spec/unit/mongoid/extensions/array/conversions_spec.rb",
     "spec/unit/mongoid/extensions/object/conversions_spec.rb"
  ]
  s.homepage = %q{http://github.com/durran/mongoid}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Mongoid}
  s.test_files = [
    "spec/integration/mongoid/document_spec.rb",
     "spec/spec_helper.rb",
     "spec/unit/mongoid/associations/belongs_to_association_spec.rb",
     "spec/unit/mongoid/associations/decorator_spec.rb",
     "spec/unit/mongoid/associations/factory_spec.rb",
     "spec/unit/mongoid/associations/has_many_association_spec.rb",
     "spec/unit/mongoid/associations/has_one_association_spec.rb",
     "spec/unit/mongoid/document_spec.rb",
     "spec/unit/mongoid/extensions/array/conversions_spec.rb",
     "spec/unit/mongoid/extensions/object/conversions_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<durran-validatable>, ["= 1.7.5"])
      s.add_runtime_dependency(%q<mislav-will_paginate>, ["= 2.3.11"])
      s.add_runtime_dependency(%q<activesupport>, ["= 2.3.4"])
      s.add_runtime_dependency(%q<mongodb-mongo>, ["= 0.14.1"])
    else
      s.add_dependency(%q<durran-validatable>, ["= 1.7.5"])
      s.add_dependency(%q<mislav-will_paginate>, ["= 2.3.11"])
      s.add_dependency(%q<activesupport>, ["= 2.3.4"])
      s.add_dependency(%q<mongodb-mongo>, ["= 0.14.1"])
    end
  else
    s.add_dependency(%q<durran-validatable>, ["= 1.7.5"])
    s.add_dependency(%q<mislav-will_paginate>, ["= 2.3.11"])
    s.add_dependency(%q<activesupport>, ["= 2.3.4"])
    s.add_dependency(%q<mongodb-mongo>, ["= 0.14.1"])
  end
end
