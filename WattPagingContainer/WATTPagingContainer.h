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

//  This component has been originally inspirated by Matt Gallaghers' PagingScrollViewController approach : Thank s Matt !
//  http://www.cocoawithlove.com/2009/01/multiple-virtual-pages-in-uiscrollview.html


#import <UIKit/UIKit.h>

#ifdef __WATT_DEV_LOG // You can define __WATT_DEV_LOG to see developments logs.
#ifndef WATTLog
#define WATTLog(format, ... ){NSLog( @"%s%d : %@",__PRETTY_FUNCTION__,__LINE__ ,[NSString stringWithFormat:(format), ##__VA_ARGS__]);}
#else
#define WATTLog(format, ... ){}
#endif
#endif

@protocol WATTPagingDataSource;
@protocol WATTPageProtocol;

/**
 `WATTPagingContainer` is an opensource alternative to UIPageController (implementing page sliding & compliant with IOS5).  `WATTPagingContainer`  is a container that allows to navigate between viewControllers using virtual paging.
 
 ## System requirements
 -IOS 5.X & more
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
 The sliding direction (NOT IMPLEMENTED YET)
 */
@property (assign,nonatomic)WATTSlidingDirection direction;

/**
  Reconfigures according to the data source.
 **/
-(void)populate;

/**
 Position without any transition to the given index
 @param index T
 */
-(void)goToPage:(NSUInteger)index;

/**
 Transition to the next page if any
 */
-(void)nextPage;

/**
 Transition to the previous page if any
 */
-(void)previousPage;

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
