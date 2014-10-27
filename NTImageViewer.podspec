Pod::Spec.new do |spec|
  spec.name         = 'NTImageViewer'
  spec.version      = '0.0.1'
  spec.summary      = 'NTImageViewer'
  spec.source_files = 'NTImageViewer.h,NTImageViewer.m'
  spec.requires_arc = true
  spec.ios.deployment_target = '5.0'
end
