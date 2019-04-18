Pod::Spec.new do |s|
  s.name         = 'Avenue'
  s.version      = '3.1.1'
  s.summary      = 'Micro-library designed to allow seamless cooperation between URLSession(Data)Task and Operation(Queue) APIs.'
  s.homepage     = 'https://github.com/radianttap/Avenue'
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { 'Aleksandar Vacić' => 'radianttap.com' }
  s.social_media_url   			= "https://twitter.com/radiantav"
  s.ios.deployment_target 		= "8.0"
  s.watchos.deployment_target 	= "3.0"
  s.tvos.deployment_target 		= "10.0"
  s.source       = { :git => "https://github.com/radianttap/Avenue.git" }
  s.source_files = 'Avenue/**/*.swift'
  s.frameworks   = 'Foundation'

  s.swift_version = '5.0'

  s.description  = <<-DESC
					URLSession framework is, on its own, incompatible with Operation API. A bit of trickery is required to make them cooperate.
					I have extended URLSessionTask with additional properties of specific closure types which allows you to overcome this incompatibility. 

					OperationQueue and Operation are great API to use when...

					* your network requests are inter-dependent on each other
					* need to implement OAuth2 or any other kind of asynchronous 3rd-party authentication mechanism
					* tight control over the number of concurrent requests towards a particular host is paramount
					* etc.
                   DESC
end
