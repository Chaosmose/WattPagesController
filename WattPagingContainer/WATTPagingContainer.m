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


#import "WATTPagingContainer.h"

@interface WATTPagingContainer ()

@end

@implementation WATTPagingContainer {
    
    UIScrollView            *_scrollView;
    
    // We use a dictionary of mutable arrays
    // Each key correspond to the "identifier" we use to dequeue
    NSMutableDictionary     *_viewControllers;
    NSMutableArray          *_identifiersHash;
    
}

#pragma mark -
#pragma mark life cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _viewControllers=[NSMutableDictionary dictionary];
    _identifiersHash=[NSMutableArray array];
    
    // Set up the main view
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view setBackgroundColor:[UIColor redColor]];
    [self.view setFrame:[self _adpativeReferenceBounds]];
    
    // Configure and add the scroll view
    
    _scrollView=[[UIScrollView alloc] initWithFrame:[self _adpativeReferenceBounds]];
    [_scrollView setBackgroundColor:[UIColor brownColor]];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setBounces:NO];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
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
    CGRect applicatonBounds=[[UIScreen mainScreen] bounds];
    if([UIApplication sharedApplication].statusBarHidden){
        return applicatonBounds;
    }else{
        // We remove the status bar height
        applicatonBounds.size.height=applicatonBounds.size.height-[UIApplication sharedApplication].statusBarFrame.size.height;
        return applicatonBounds;
    }
}


-(CGRect)_adpativeReferenceBounds{
    return [self _adaptRect:[self _referenceBounds]];
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
            CGRect pageFrame = [self _adpativeReferenceBounds];
            pageFrame.origin.y = 0;
            pageFrame.origin.x =[self _adpativeReferenceBounds].size.width * newIndex;
            controller.view.frame = pageFrame;
        }else{
            CGRect pageFrame = [self _adpativeReferenceBounds];
            pageFrame.origin.y = [self _adpativeReferenceBounds].size.height;
            controller.view.frame = pageFrame;
        }
        
    }else{
        [NSException raise:@"Inconsistency"
                    format:@"UIViewController should conform to WATTPageProtocol current class is %@",NSStringFromClass([controller class])];
    }
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
    [self goToPage:0];
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
    /*

    CGFloat pageWidth = _scrollView.frame.size.width;
    float fractionalPage = _scrollView.contentOffset.x / pageWidth;
    
	NSInteger lowerNumber = floor(fractionalPage);
	NSInteger upperNumber = lowerNumber + 1;
     if (lowerNumber == currentPage.pageIndex){
     if (upperNumber != nextPage.pageIndex){
     [self applyNewIndex:upperNumber pageController:nextPage];
     }
     }else if (upperNumber == currentPage.pageIndex){
     if (lowerNumber != nextPage.pageIndex){
     [self applyNewIndex:lowerNumber pageController:nextPage];
     }
     }else{
     if (lowerNumber == nextPage.pageIndex){
     [self applyNewIndex:upperNumber pageController:currentPage];
     }else if (upperNumber == nextPage.pageIndex){
     [self applyNewIndex:lowerNumber pageController:currentPage];
     }else{
     [self applyNewIndex:lowerNumber pageController:currentPage];
     [self applyNewIndex:upperNumber pageController:nextPage];
     }
     }
     [currentPage updateTextViews:NO];
     [nextPage updateTextViews:NO];
     */
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)newScrollView {
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




@end