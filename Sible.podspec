Pod::Spec.new do |s|
  s.name         = "Sible"
  s.version      = "0.1.1"
  s.summary      = "Sible iOS SDK"
  s.homepage     = "http://github.com/emberlight/sible"
  s.platform     = :ios, "7.0"
  s.license      = { :type => 'MIT' }
  s.authors      = { 'Emberlight' => 'kevinr@emberlight.co' }
  s.source       = { :git => "https://github.com/emberlight/sible.git", :tag => "0.1.1" }
  s.public_header_files = "release/Sible.h"
  s.source_files       = 'release/Sible.h'
  s.preserve_paths = "release/libSible.a"
	s.ios.vendored_library = "release/libSible.a"
  s.requires_arc = true
end
