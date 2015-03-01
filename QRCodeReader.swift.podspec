Pod::Spec.new do |s|
  s.name             = 'QRCodeReader.swift'
  s.version          = '3.0.0'
  s.license          = 'MIT'
  s.summary          = 'Simple QRCode reader in Swift'
  s.homepage         = 'https://github.com/yannickl/QRCodeReader.swift.git'
  s.social_media_url = 'https://twitter.com/yannickloriot'
  s.authors          = { 'Yannick Loriot' => 'contact@yannickloriot.com' }
  s.source           = { :git => 'https://github.com/yannickl/QRCodeReader.swift.git', :tag => s.version }

  s.ios.deployment_target = '8.0'

  s.framework    = 'AVFoundation'
  s.source_files = 'QRCodeReader/*.swift'
  s.requires_arc = true
end
