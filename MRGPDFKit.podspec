Pod::Spec.new do |s|
  s.name             = "MRGPDFKit"
  s.version          = "0.1.0"
  s.summary          = "A simple objective-C Toolkit to fill PDF forms."
  s.description      = "Add this objective-C Toolkit to add PDF form filling capability in your project."
  s.homepage         = "https://github.com/mirego/MRGPDFKit"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'BSD 3-Clause'
  s.author           = { 'Mirego' => 'info@mirego.com' }
  s.source           = { :git => "https://github.com/mirego/MRGPDFKit.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'MRGPDFKit/**/*.{h,m}'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'MCUIViewLayout', '~> 0.5.1'
end
