Pod::Spec.new do |s|
  s.name             = "Avenue"
  s.version          = "0.0.1"
  s.summary          = "A Networking Infrastructure"
  s.homepage         = "https://github.com/MediaHound/Avenue"
  s.license          = 'MIT'
  s.author           = { "Dustin Bachrach" => "dustin@mediahound.com" }
  s.source           = { :git => "https://github.com/MediaHound/Avenue.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m}'
  s.private_header_files = "Pod/Classes/**/*+Internal.h"

  s.dependency 'AFNetworking'
  # s.dependency 'AgnosticLogger'
  s.dependency 'KVOController'
  s.dependency 'PromiseKit/Promise'
end
