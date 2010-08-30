# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{luck}
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Danopia"]
  s.date = %q{2010-08-29}
  s.description = %q{Pure-ruby CLI UI system. Includes multiple panes in a display and multiple controls in a pane. luck is lucky (as opposed to ncurses being cursed)}
  s.email = %q{me.github@danopia.net}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.md"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.md",
     "Rakefile",
     "VERSION",
     "lib/luck.rb",
     "lib/luck/alert.rb",
     "lib/luck/ansi.rb",
     "lib/luck/button.rb",
     "lib/luck/control.rb",
     "lib/luck/display.rb",
     "lib/luck/label.rb",
     "lib/luck/listbox.rb",
     "lib/luck/pane.rb",
     "lib/luck/progressbar.rb",
     "lib/luck/textbox.rb",
     "luck.gemspec"
  ]
  s.homepage = %q{http://github.com/danopia/luck}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Pure-ruby CLI UI system}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
  end
end

