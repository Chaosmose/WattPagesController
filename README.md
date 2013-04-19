#WATTPagingContainer#

WATTPagingContainer is an opensource alternative to UIPageController (implementing vertical and horizontal optimal page sliding & compliant with IOS SDK>=5.0).  
WATTPagingContainer is a container that allows to navigate between viewControllers using virtual paging.
 
 
##How to use :##

Import WATTPagesController.h,m in your project. 
 
If you use cocoapods put this line in your _Podfile_ :

<code>
pod 'WattPagesController', {:git => 'https://github.com/benoit-pereira-da-silva/WattPagesController.git'} 
</code>

 1-Override WATTPagingContainer  
 2-conform to WATTPagingDataSource  
 3-Any added viewContoller must conform to WATTPageProtocol  


##System requirements##

 -IOS >= 5.0 
 -ARC
 

