Pod::Spec.new do |s|
  s.name             = 'JSDatePickerView'
  s.version          = ‘2.0.2’
  s.summary          = 'This is a custom DatePicker UIView'

  s.description      = <<-DESC
This custom DatePicker UIView allows the user to switch dates in different ways.  The user could use the built in arrows to switch day by day.
Or, the user could press on the UIView and use the custom popout calendar to select a new day.
                       DESC

  s.homepage         = 'https://github.com/jseidman95/JSDatePickerView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jesse Seidman' => 'seidmanjesse@gmail.com' }
  s.source           = { :git => 'https://github.com/jseidman95/JSDatePickerView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.3.1'
  s.source_files = 'JSDatePickerView/**/*.swift'

end

