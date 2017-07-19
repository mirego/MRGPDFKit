Pod::Spec.new do |s|
  s.name             = "MRGPDFKit"
  s.version          = "1.0.0"
  s.summary          = "A simple objective-C Toolkit to fill PDF forms."
  s.description      = "Add this objective-C Toolkit to add PDF form filling capability in your project."
  s.homepage         = "https://github.com/mirego/MRGPDFKit"
  s.license          = 'BSD 3-Clause'
  s.author           = { 'Mirego' => 'info@mirego.com' }
  s.source           = { :git => "https://github.com/mirego/MRGPDFKit.git", :tag => s.version.to_s }
  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.source_files     = 'MRGPDFKit/**/*.{h,m}'

  s.dependency 'MCUIViewLayout', '~> 0.5.1'
end
