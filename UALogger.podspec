Pod::Spec.new do |s|
  s.name         = "UALogger"
  s.version      = "0.2.3"
  s.summary      = "UALogger is a logging tool for iOS and Mac apps."
  s.description  = <<-DESC
                   UALogger is a logging tool for iOS and Mac apps. It allows you to customize the log format, when to log to the console, and allows collection of the console log for your application.
                   DESC
  s.homepage     = "https://github.com/UrbanApps/UALogger"
  s.license      = 'MIT'
  s.author       = { "Matt Coneybeare" => "coneybeare@urbanapps.com" }
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  s.requires_arc = true
  s.source       = { :git => "https://github.com/UrbanApps/UALogger.git", :tag => s.version.to_s }
  s.source_files  = 'UALogger.h,m'
end
