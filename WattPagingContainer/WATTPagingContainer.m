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


typedef enum {
    WATT_UnknowTrend,
    WATT_TrendNext,
    WATT_TrendPrevious
} WATTMovementTrend;


#import "WATTPagingContainer.h"

@interface WATTPagingContainer ()

@end

@implementation WATTPagingContainer {
    
    UIScrollView            *_scrollView;
    
    // We use a dictionary of mutable arrays
    // Each key correspond to the "identifier" we use to dequeue
    NSMutableDictionary     *_viewControllers;
    NSMutableArray          *_identifiersHash;
    WATTMovementTrend       _trend; // we could use this state to perform predictive preloading in a future version
    
}

#pragma mark -
#pragma mark life cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _viewControllers=[NSMutableDictionary dictionary];
    _identifiersHash=[NSMutableArray array];
    _trend=WATT_UnknowTrend;
    
    // Set up the main view
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view setBackgroundColor:[UIColor redColor]];
    [self.view setBounds:[self _adpativeReferenceBounds]];
    
    // Configure and add the scroll view
    
    _scrollView=[[UIScrollView alloc] initWithFrame:[self _adpativeReferenceBounds]];
    [_scrollView setBackgroundColor:[UIColor brownColor]];
    [_scrollView setPagingEnabled:YES];
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
    
    [_scrollView removeFromSuperview];
    _scrollView = nil;
    
    [_viewControllers removeAllObjects];
    _viewControllers=nil;
    
    [_identifiersHash removeAllObjects];
    _identifiersHash=nil;
}


#pragma mark - 
#pragma mark Rect and Bounds


-(CGRect)_referenceBounds{
    return [[UIScreen mainScreen] bounds];
}

-(CGRect)_adpativeReferenceBounds{
    CGRect refBounds=[self _adaptRect:[self _referenceBounds]];
    // we exclude the status bar if necessary
    CGRect barFrame= [self _adaptRect:[UIApplication sharedApplication].statusBarFrame];
    refBounds.origin=CGPointMake(0.f, 0.f);
    refBounds.size.height=refBounds.size.height-barFrame.size.height;
    return refBounds;
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


- (void)_applyNewPageIndex:(NSInteger)newIndex{
    
    UIViewController * __weak controller=[self.dataSource viewControllerForIndex:newIndex];
    NSString *identifier=NSStringFromClass([controller class]);
    [self _addIfNecessaryViewController:controller withIdentifier:identifier];
    [_identifiersHash insertObject:[identifier copy] atIndex:newIndex];
    
    if([controller conformsToProtocol:@protocol(WATTPageProtocol)]){
        
        NSInteger pageCount = [self.dataSource pageCount];
        BOOL outOfLimits = newIndex >= pageCount || newIndex < 0;
        
        if (!outOfLimits){
            [self _adjustViewController:controller atIndex:newIndex];
        }else{
            //CGRect pageFrame = [self _adpativeReferenceBounds];
            //pageFrame.origin.y = [self _adpativeReferenceBounds].size.height;
            //controller.view.frame = pageFrame;
        }
        
    }else{
        [NSException raise:@"Inconsistency"
                    format:@"UIViewController should conform to WATTPageProtocol current class is %@",NSStringFromClass([controller class])];
    }
}


-(void)_adjustViewController:(UIViewController*)controller atIndex:(NSInteger)index{
    CGRect pageFrame = [self _adpativeReferenceBounds];
    pageFrame.origin.y = 0;
    CGFloat x=[self _adpativeReferenceBounds].size.width * (CGFloat)index;
    pageFrame.origin.x = x;
    controller.view.frame = pageFrame;
}


-(void)_addIfNecessaryViewController:(UIViewController*)controller withIdentifier:(NSString*)identifier{
    if([[_viewControllers allKeys] indexOfObject:identifier]==NSNotFound){
        [_viewControllers setValue:[NSMutableArray array] forKey:identifier];
    }
    NSMutableArray *list=[_viewControllers valueForKey:identifier];
    if([list indexOfObject:controller]==NSNotFound){
        [list addObject:controller];
        if(![controller.parentViewController isEqual:self]){
            [controller willMoveToParentViewController:self];
            [self addChildViewController:controller];
            [controller didMoveToParentViewController:self];
            [controller.view setFrame:[self _referenceBounds]];
            [_scrollView addSubview:controller.view]; //
        }
    }
}



#pragma mark -


-(void)populate{
    NSInteger widthCount = [self.dataSource pageCount];
	if (widthCount == 0){
		widthCount = 1;
	}
	
    _scrollView.contentSize =CGSizeMake(_scrollView.frame.size.width * widthCount,_scrollView.frame.size.height);
	_scrollView.contentOffset = CGPointMake(0, 0);
    
    _pageIndex=0;
    
	[self _applyNewPageIndex:0];
    [self _applyNewPageIndex:1];
    /*
    if([self.dataSource pageCount]>2){
        [self _applyNewPageIndex:2];
        [self goToPage:1];
    }*/
    
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
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.frame.size.width * index, 0.f, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:NO];
}


-(UIViewController*)dequeueViewControllerWithClass:(Class)theClass{
    NSString*identifier=NSStringFromClass(theClass);
    if([[_viewControllers allKeys] indexOfObject:identifier]==NSNotFound)
        return nil;
    NSMutableArray *list=[_viewControllers valueForKey:identifier];
    for (UIViewController *controller in list) {
        if(!CGRectIntersectsRect(_scrollView.bounds, controller.view.frame)){
            return controller;
        }
    }
    return nil;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender{

    CGFloat pageWidth = _scrollView.frame.size.width;
    CGFloat fractionalPage = _scrollView.contentOffset.x / pageWidth;
    NSInteger newIndex=floor(fractionalPage);
    
    if(newIndex!=_pageIndex){
         NSLog(@"INDEX HAS CHANGED %i",newIndex);
        _pageIndex=newIndex;
        [self _applyNewPageIndex:newIndex];
        [self _dump];
    }
    
    CGFloat currentIndex=(CGFloat)_pageIndex;
    
    if(fractionalPage==currentIndex){
       
        _trend=WATT_UnknowTrend;
    }else if(fractionalPage>=currentIndex){
        _trend=WATT_TrendNext;
    }else{
        _trend=WATT_TrendPrevious;
    }
     NSLog(@"IDX : %f fractionalPage :%f %@",currentIndex,fractionalPage,_trend==WATT_TrendNext?@"NEXT":_trend==WATT_TrendPrevious?@"PREVIOUS":@"UNKNOWN");
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)newScrollView {
     NSLog(@"***");
    /*
    CGFloat pageWidth = _scrollView.frame.size.width;
    float fractionalPage = _scrollView.contentOffset.x / pageWidth;
	NSInteger nearestNumber = lround(fractionalPage);
    
    
     if (currentPage.pageIndex != nearestNumber){
     UIViewController *swapController = _currentPageController;
     _currentPageController = _nextPageController;
     _nextPageController = swapController;
     }
     
     [currentPage updateTextViews:YES];
     */
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
    // Adjust
    //[self _adjustViewController: atIndex:_pageIndex];
}



#pragma mark -
#pragma mark Debug facility


-(void)_dump{
    NSLog(@"%@",self);
}

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

@end