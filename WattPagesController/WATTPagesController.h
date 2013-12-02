//
//  WATTViewController.h
//  WattPagingContainer
//
//  Created by Benoit Pereira da Silva on 15/02/13.
//  Copyright (c) 2013  http://www.pereira-da-silva.com

// This file is part of WattPagingContainer
//
// WattPagingContainer is free software: you can redistribute it and/or modify
// it under the terms of the  GNU LESSER GENERAL PUBLIC LICENSE as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// WattPagingContainer is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU LESSER GENERAL PUBLIC LICENSE for more details.

// You should have received a copy of the  GNU LESSER GENERAL PUBLIC LICENSE
// along with WattPagingContainer  If not, see <http://www.gnu.org/licenses/>

#import <UIKit/UIKit.h>

 // You can define __WATT_DEV_LOG anyware to see developments logs.
#ifdef __WATT_DEV_LOG      
#define WATTLog(format, ... ){NSLog( @"%s%d : %@",__PRETTY_FUNCTION__,__LINE__ ,[NSString stringWithFormat:(format), ##__VA_ARGS__]);}
#else
#define WATTLog(format, ... ){}
#endif

@protocol WATTPagingDataSource;
@protocol WATTPageProtocol;

/**
 `WATTPagingContainer` is an opensource alternative to UIPageController (implementing vertical and horiontal optimal page sliding & compliant with IOS>=5.0).  `WATTPagingContainer`  is a container that allows to navigate between viewControllers using virtual paging.
 
 ## System requirements
 -IOS >= 5.0 
 -ARC
 
 ## Usage 
 
 1-Override WATTPagingContainer
 2-conform to WATTPagingDataSource
 3-Any added viewContoller must conform to WATTPageProtocol
 
**/

/**
 Future extension (vertical support)
 */
typedef enum {
    WATTSlidingDirectionHorizontal,
    WATTSlidingDirectionVertical
} WATTSlidingDirection;



@interface WATTPagesController : UIViewController<UIScrollViewDelegate>{
}

/**
 The current page index
 */
@property (readonly,nonatomic)NSInteger pageIndex;

/**
 The datasource
 **/
@property (assign,nonatomic)id<WATTPagingDataSource>dataSource;

/**
 The sliding direction
 */
@property (assign,nonatomic)WATTSlidingDirection direction;

/**
 default YES. if YES, stop on multiples of view bounds
 **/
@property (assign,nonatomic)BOOL pagingEnabled;

/**
 default YES. Blocks the scroller
 **/
@property (assign,nonatomic)BOOL scrollEnabled;


/**
 default NO. if YES, bounces past edge of content and back again
 **/
@property (assign,nonatomic)BOOL bounces;

/**
 default blackColor
 **/
@property (strong,nonatomic)UIColor *backgroundColor;

/**
  Reconfigures according to the data source.
 **/
-(void)populateAndGoToIndex:(NSUInteger)index
                   animated:(BOOL)animated;

/**
 Position without any transition to the given index
 @param index 
 @param animated if YES the transition will be animated
 */
-(void)goToPage:(NSInteger)index
       animated:(BOOL)animated;

/**
 Transition to the next page if any
 */
-(void)nextPageAnimated:(BOOL)animated;

/**
 Transition to the previous page if any
 */
-(void)previousPageAnimated:(BOOL)animated;

/**
 Returns a viewController that is off screen, to be reconfigured
 @param theClass The class of the desired view controller
 @return An `UIViewController` 
 */
-(UIViewController*)dequeueViewControllerWithClass:(Class)theClass;


/**
 Returns the curent viewController (the view Controller that is closer to the center.)
 @return An `UIViewController`
 */
-(UIViewController*)currentViewController;


/**
 Does nothing but can be overriden to perform an action on index change.
 @param pageIndex the new page index
 */
-(void)pageIndexDidChange:(NSInteger)pageIndex;

/**
 *  Relays a setScrollsToTop to the current view controller
 *
 *  @param scrollToTop a boolean value
 */
-(void)setScrollToTopOfCurrentViewController:(BOOL)scrollToTop;

@end


#pragma mark - 
#pragma mark WATTPagingDataSource

@protocol WATTPagingDataSource <NSObject>
@required
-(UIViewController*)viewControllerForIndex:(NSUInteger)index;
-(NSUInteger)pageCount;
@end


#pragma mark -
#pragma mark WATTPageProtocol 

@protocol WATTPageProtocol <NSObject>
@required
-(void)configureWithModel:(id)model;
@end
