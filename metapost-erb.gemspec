Gem::Specification.new do |s|
  s.name = "metapost-erb"
  s.required_ruby_version = "~>1.9.1"
  s.version = '0.0.1'
  s.author = "Thomas Counsell, Green on Black Ltd"
  s.email = "metapost-erb@greenonblack.com"
  s.homepage = "http://github.com/tamc/metapost-erb"
  s.platform = Gem::Platform::RUBY
  s.summary = "Helps to programatically create metapost files, making use of erb templates"
  s.files = ["LICENSE", "README", "{spec,lib,bin,examples}/**/*"].map{|p| Dir[p]}.flatten
  s.executables = ["metapost-erb"]
  s.require_path = "lib"
  s.has_rdoc = false
end