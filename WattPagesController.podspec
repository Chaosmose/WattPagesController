Pod::Spec.new do |s|
  s.platform = :ios, '5.0'
  s.homepage     = 'https://github.com/benoit-pereira-da-silva/WattPagesController'
  s.name         = 'WattPagesController'
  s.version      = '1.0.1'
  s.summary      = 'A sliding page controller container with view controllers recycling abilities.'
  s.license      = 'LGPL'  
  s.author = {
    'Benoit Pereira da Silva' => 'benoit.pereiradasilva@gmail.com'
  }
  s.source = {
    :git => 'https://github.com/benoit-pereira-da-silva/WattPagesController.git',:tag => '1.0.1', :submodules => true }
  s.source_files = 'WattPagesController/*.{h,m}'
  s.requires_arc = true
end
