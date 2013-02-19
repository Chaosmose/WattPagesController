//
//  WATTViewController.h
//  WattPagingContainer
//
//  Created by Benoit Pereira da Silva on 15/02/13.
//  Copyright (c) 2013  http://www.pereira-da-silva.com

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <UIKit/UIKit.h>

 // You can define __WATT_DEV_LOG anyware to see developments logs.
#ifdef __WATT_DEV_LOG      
#ifndef WATTLog
#define WATTLog(format, ... ){NSLog( @"%s%d : %@",__PRETTY_FUNCTION__,__LINE__ ,[NSString stringWithFormat:(format), ##__VA_ARGS__]);}
#else
#define WATTLog(format, ... ){}
#endif
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



@interface WATTPagingContainer : UIViewController<UIScrollViewDelegate>{
}

/**
 The current page index
 */
@property (readonly,nonatomic)NSUInteger pageIndex;

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
-(void)populate;

/**
 Position without any transition to the given index
 @param index 
 @param animated if YES the transition will be animated
 */
-(void)goToPage:(NSUInteger)index
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
