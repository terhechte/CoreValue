Pod::Spec.new do |spec|
  spec.name = 'CoreValue'
  spec.version = '0.1.2'
  spec.summary = 'Lightweight Framework for using Core Data with Value Types'
  spec.homepage = 'https://github.com/terhechte/CoreValue'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = {
    'Benedikt Terhechte' => 'terhechte@gmail.com',
  }
  spec.social_media_url = 'http://twitter.com/terhechte'
  spec.source = { :git => 'https://github.com/terhechte/CoreValue.git', :tag => "v#{spec.version}" }
  spec.source_files = 'CoreValue/*.{h,swift}'
  spec.requires_arc = true
  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.9'
end