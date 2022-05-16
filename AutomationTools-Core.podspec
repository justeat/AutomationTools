Pod::Spec.new do |s|
  s.name             = 'AutomationTools-Core'
  s.version          = ENV['LIB_VERSION']
  s.summary          = 'iOS UI test framework and guidelines'
  s.homepage         = 'https://github.com/justeat/AutomationTools'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = 'Just Eat Takeaway iOS Team'
  s.source           = { :git => 'https://github.com/justeat/AutomationTools.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  
  s.subspec 'Core' do |ss|
    ss.ios.source_files = ['AutomationTools/Classes/Core/**/*']
    ss.ios.frameworks = ['Foundation', 'XCTest']
  end
  
end
