Pod::Spec.new do |s|
  s.name             = 'AutomationTools'
  s.version          = '3.0.0'
  s.summary          = 'iOS UI test framework and guidelines'
  s.homepage         = 'https://github.com/justeat/AutomationTools'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Alberto De Bortoli' => 'alberto.debortoli@just-eat.com',
                         'Sneha Narayana Swamy' => 'sneha.narayanaswamy@just-eat.com' }
  s.source           = { :git => 'https://github.com/justeat/AutomationTools.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  
  s.subspec 'HostApp' do |ss|
      ss.ios.source_files = ['AutomationTools/Classes/HostApp/**/*']
  end
  
  s.subspec 'Core' do |ss|
      ss.ios.source_files = ['AutomationTools/Classes/Core/**/*']
      ss.ios.frameworks = ['Foundation', 'XCTest']
  end
  
end
