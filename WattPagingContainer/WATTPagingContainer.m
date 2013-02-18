//
//  WATTViewController.m
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

// http://developer.apple.com/library/ios/#featuredarticles/ViewControllerPGforiPhoneOS/CreatingCustomContainerViewControllers/CreatingCustomContainerViewControllers.html



typedef enum {
    WATT_IsStable,
    WATT_TrendNext,
    WATT_TrendPrevious
} WATTMovementTrend;


#import "WATTPagingContainer.h"

@interface WATTPagingContainer ()

@end

@implementation WATTPagingContainer {
    
    // The scrollview that host the other views.
    UIScrollView            *_scrollView;
    
    // We use a dictionary of mutable arrays
    // Each key correspond to the "identifier" we use to dequeue
    
    NSMutableDictionary     *_viewControllers;
    NSMutableArray          *_indexes;
    
    CGFloat                 _lastFractionalPage;   // We store the _lastFractionalPage when scrolling to determine the trend
    WATTMovementTrend       _scrollingTrend;        // Reflects the current scrolling trend;
    NSUInteger               _bufferSize;           // This variable will allow perfomance tunning 2 is the minima
    NSUInteger              _futureIndex;
}

#pragma mark -
#pragma mark life cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    BOOL l=[self _isLandscapeOrientation];
    if(l){
        // IOS 5 BUG
        WATTLog(@"**");
    }
    
    _viewControllers=[NSMutableDictionary dictionary];
    _indexes=[NSMutableArray array];
    _scrollingTrend=WATT_IsStable;
    _lastFractionalPage=0.f;
    _bufferSize=2;              //We use only 2 view controllers as our pages are full screen.
    
    
    // Set up the main view
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view setBackgroundColor:[UIColor redColor]];
    [self.view setBounds:[self _adpativeReferenceBounds]];
    
    // Configure and add the scroll view
    
    _scrollView=[[UIScrollView alloc] initWithFrame:[self _adpativeReferenceBounds]];//initWithFrame:CGRectMake(10, 10, 512, 512)];
    [_scrollView setBackgroundColor:[UIColor brownColor]];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setClipsToBounds:YES];
    [_scrollView setBounces:NO];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_scrollView setDelegate:self];
    [self.view addSubview:_scrollView];
    
}



-(void)viewDidUnload{
    [super viewDidUnload];
    [_scrollView removeFromSuperview];
    _scrollView = nil;
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)removeFromParentViewController{
    [super removeFromParentViewController];
    for(NSString*key in _viewControllers){
        NSArray *list=[_viewControllers objectForKey:key];
        for (UIViewController*controller in list) {
            [controller willMoveToParentViewController:nil];
            [controller.view removeFromSuperview];
            [controller removeFromParentViewController];
        }
    }
    
    [_indexes removeAllObjects];
    _indexes=nil;
    
    [_viewControllers removeAllObjects];
    _viewControllers=nil;
    
    [_scrollView removeFromSuperview];
    _scrollView = nil;
    
    
    
}


#pragma mark -
#pragma mark Rect and Bounds


-(CGRect)_referenceBounds{
    return [[UIScreen mainScreen] applicationFrame];
}

-(CGRect)_adpativeReferenceBounds{
    return [self _adaptRect:[self _referenceBounds]];;
}

-(CGRect)_rectRotate:(CGRect)rect{
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
}

-(CGRect)_adaptRect:(CGRect)rect{
    return [self _isLandscapeOrientation]?[self _rectRotate:rect]:rect;
}


-(BOOL)_isLandscapeOrientation{
    return UIDeviceOrientationIsLandscape([self _currentOrientation]);
}

-(UIInterfaceOrientation)_currentOrientation{
    return [[UIApplication sharedApplication] statusBarOrientation];
}


#pragma mark -
#pragma mark


- (void)_preparePageAtIndex:(NSUInteger)newIndex{
    
    if([_indexes count]>newIndex){
        if([_indexes objectAtIndex:newIndex] && [[_indexes objectAtIndex:newIndex]class]!=[NSNull class]){
            // There is already a view controller prepared for this index
            return ;
        }
    }
    
    if(newIndex>[self.dataSource pageCount]){
        WATTLog(@"BUG");
    }
    
    UIViewController * __weak controller=[self.dataSource viewControllerForIndex:newIndex];
    NSString *identifier=NSStringFromClass([controller class]);
    
    [self _register:controller atIndex:newIndex];
    
    [self _addIfNecessaryViewController:controller
                         withIdentifier:identifier];
    
    if (! (newIndex >= [self.dataSource pageCount]) ){
        [self _positionViewFrom:controller
                        atIndex:newIndex];
    }
    
#ifdef __WATT_DEV_LOG
    WATTLog(@"Preparing index : %i [%i] %@",newIndex,[self _countViewControllers],_indexes);
#endif
    
}


// We add a we controller once only
-(void)_addIfNecessaryViewController:(UIViewController*)controller
                      withIdentifier:(NSString*)identifier {
    
    if( [[_viewControllers allKeys] indexOfObject:identifier] == NSNotFound ){
        [_viewControllers setValue:[NSMutableArray array] forKey:identifier];
    }
    
    NSMutableArray *list=[_viewControllers valueForKey:identifier];
    if( [list indexOfObject:controller] == NSNotFound ){
        [list addObject:controller];
        if(![controller.parentViewController isEqual:self]){
            [self addChildViewController:controller];
            [controller.view setFrame:[self _referenceBounds]];
            [_scrollView addSubview:controller.view]; //
            [controller didMoveToParentViewController:self];
        }
    }
}


-(void)_positionViewFrom:(UIViewController*)controller
                 atIndex:(NSUInteger)index{
    CGRect pageFrame = [self _adpativeReferenceBounds];
    pageFrame.origin.y = 0;
    CGFloat x=[self _adpativeReferenceBounds].size.width * (CGFloat)index;
    pageFrame.origin.x = x;
    controller.view.frame = pageFrame;
    
}



-(void)_register:(UIViewController*)viewController
         atIndex:(NSUInteger)index {
    WATTLog(@"REGISTERING %@ at index : %i",viewController,index);
    NSUInteger idx=[_indexes indexOfObject:viewController];
    if(idx!=index){
        if(idx!=NSNotFound){
            // We place a NSNull object reference to the previous index
            [_indexes replaceObjectAtIndex:idx
                                withObject:[NSNull null]];
        }
        //We place a reference viewController at its new index.
        if(index>=[_indexes count]){
            [_indexes insertObject:viewController
                           atIndex:index];
        }else{
            [_indexes replaceObjectAtIndex:index
                                withObject:viewController];
        }
    }
}


-(UIViewController*)dequeueViewControllerWithClass:(Class)theClass{
    NSString*identifier=NSStringFromClass(theClass);
    if([[_viewControllers allKeys] indexOfObject:identifier]==NSNotFound)
        return nil;// There are no view controller to recycle with that class.
    
    // Let's chech if there a free (currently off screen) view controller.
    NSMutableArray *list=[_viewControllers valueForKey:identifier];
    for (UIViewController *controller in list) {
        NSUInteger idx=[_indexes indexOfObject:controller];
        if(idx!=NSNotFound && idx!=_pageIndex && idx!=_futureIndex){
            return controller;
        }
    }
    // There is no free view controller.
    return nil;
}



#pragma mark -

-(void)populate{
    
    NSInteger widthCount = [self.dataSource pageCount];
    if (widthCount == 0){
        widthCount = 1;
    }
    
    _scrollView.contentSize =CGSizeMake(_scrollView.frame.size.width * widthCount,_scrollView.frame.size.height);
    _scrollView.contentOffset = CGPointMake(0, 0);
    
    _pageIndex=_futureIndex=0;
    [self _preparePageAtIndex:0];
    
}


-(void)nextPage{
    _pageIndex++;
    [self goToPage:_pageIndex];
}


-(void)previousPage{
    _pageIndex++;
    [self goToPage:_pageIndex];
}


-(void)goToPage:(NSUInteger)index{
    _pageIndex=index;
    _futureIndex=index;
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.frame.size.width * index, 0.f, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:NO];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender{
    
    CGFloat pageWidth               =   _scrollView.frame.size.width;
    CGFloat fractionalPage          =   _scrollView.contentOffset.x / pageWidth;
    CGFloat roundedFractionalPage   =   roundf(fractionalPage);
    
    WATTMovementTrend currentTrend;
    
    if( fractionalPage == roundedFractionalPage ){
        currentTrend=WATT_IsStable;
    }else if(fractionalPage>_lastFractionalPage){
        currentTrend=WATT_TrendNext;
    }else{
        currentTrend=WATT_TrendPrevious;
    }
    
    _lastFractionalPage=fractionalPage;
    BOOL trendHasChanged = (_scrollingTrend != currentTrend);
    _scrollingTrend=currentTrend;
    
    if(_scrollingTrend==WATT_IsStable){
       _pageIndex=roundedFractionalPage;
        WATTLog(@"Page has changed : %i",_pageIndex);
    }
    
    if(trendHasChanged && _scrollingTrend!=WATT_IsStable){
        // Future index is an NSUInteger so we must keep a positive value.
        if(_scrollingTrend==WATT_TrendPrevious){
            if(_pageIndex>0){
                _futureIndex=_pageIndex-1;
            }else{
                _futureIndex=0;
            }
        }else{
            _futureIndex=_pageIndex+1;
        }
        [self _preparePageAtIndex:_futureIndex];
    }
    
    //WATTLog(@"%f _pageIndex %i _futureIndex %i %@",_lastFractionalPage,_pageIndex,_futureIndex,_scrollingTrend==WATT_TrendNext?@"NEXT":_scrollingTrend==WATT_TrendPrevious?@"PREVIOUS":@"STABILIZED");
}


#pragma mark - Autorotation

//IOS 6
-(BOOL)shouldAutorotate{
    return YES;
}
// IOS 6
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}
//IOS 6
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self _currentOrientation];
}


#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
// Retro compatibility with IOS 5 (Deprecated)
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
#endif


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


#pragma mark -
#pragma mark Debug facility


-(NSString*)description{
    NSMutableString *s=[NSMutableString string];
    for(NSString*key in _viewControllers){
        NSArray *list=[_viewControllers objectForKey:key];
        [s appendFormat:@"Identifier : %@ [%i]",key,[list count]];
        for (UIViewController*controller in list) {
            [s appendFormat:@"\n%@",controller];
        }
    }
    return s;
}


-(NSInteger)_countViewControllers{
    NSInteger counter=0;
    for(NSString*key in _viewControllers){
        NSArray *list=[_viewControllers objectForKey:key];
        for (UIViewController*controller in list) {
            counter++;
        }
    }
    return counter;
}


@end