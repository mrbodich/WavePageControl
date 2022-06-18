Pod::Spec.new do |s|
  s.name             = 'WavePageControl'
  s.version          = '1.0.0'
  s.summary          = 'WavePageControl is a powerful & elegant way to organise pages indicators or thumbnails.'

  s.description      = <<-DESC
WavePageControl is a Page Control that can organise and show all pages on a single screen.
                       DESC

  s.homepage         = 'https://github.com/mrbodich/WavePageControl'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Bogdan Chornobryvets' => 'bogdan.chornobryvets@gmail.com' }
  s.source           = { :git => 'https://github.com/mrbodich/WavePageControl.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files     = 'Sources/WavePageControl/**/*'
end
