
Pod::Spec.new do |s|
s.name          = 'DMSegmentedPager'
s.version       = '1.0.0'
s.summary       = ''
s.swift_version = '4.0'
s.homepage      = 'https://github.com/DominicMDev/DMSegmentedPager'
s.license       = { :type => 'MIT', :file => 'LICENSE.md' }
s.authors       = { "Dominic Miller" => "dominicmdev@gmail.com", "Maxime Epain" => "maxime.epain@gmail.com" }
s.source        = { :git => "https://github.com/DominicMDev/DMSegmentedPager.git", :tag => s.version }
s.platform      = :ios, '10.0'
s.requires_arc  = true
s.source_files  = 'DMSegmentedPager/*.swift'
s.framework     = 'QuartzCore'

s.dependency 'DMSegmentedControl', '~> 1.0'

end