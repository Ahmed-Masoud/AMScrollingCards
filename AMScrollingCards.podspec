#
# Be sure to run `pod lib lint AMScrollingCards.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AMScrollingCards'
  s.version          = '1.0'
  s.summary          = 'This pod was created to offer a ui component of swiping horizontal cards'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This pod was created to offer a ui component of swiping horizontal cards with a peek of next and previous cards using a collection view to make sure its reliable and memory efficient
                       DESC

  s.homepage         = 'https://github.com/Ahmed-Masoud-R/AMScrollingCards'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ahmed-Masoud-R' => 'ahmed.ehab@rubikal.com' }
  s.source           = { :git => 'https://github.com/Ahmed-Masoud-R/AMScrollingCards.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.ios.deployment_target = '10.0'

  s.source_files = 'AMScrollingCards/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AMScrollingCards' => ['AMScrollingCards/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
