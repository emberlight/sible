Pod::Spec.new do |s|
  s.name         = "Sible"
  s.version      = "0.1"
  s.summary      = "Sible iOS SDK"
  s.homepage     = "http://github.com/emberlight/sible"
  s.platform     = :ios, "7.0"
  s.license      = { :type => 'MIT' }
  s.authors      = { 'Emberlight' => 'kevinr@emberlight.co' }
  s.source       = { :git => "https://github.com/emberlight/sible.git", :branch => "0.1.0" }
  s.public_header_files = "Sible.h"
  s.preserve_paths = "libSible.a"
	s.ios.vendored_library = "libSible.a"
  s.requires_arc = true
end
