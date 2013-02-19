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


#import "WATTPagesController.h"

@interface WATTPagesController ()

@end

@implementation WATTPagesController {
    
    // The scrollview that host the other views.
    UIScrollView            *_scrollView;
    
    // We use a dictionary of mutable arrays
    // Each key correspond to the "identifier" we use to dequeue
    
    NSMutableDictionary     *_viewControllers;
    NSMutableArray          *_indexes;
    
    NSUInteger              _futureIndex; // The predictible next index.
    
    
}

#pragma mark -
#pragma mark life cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _viewControllers=[NSMutableDictionary dictionary];
    _indexes=[NSMutableArray array];
    _pagingEnabled=YES;
    _bounces=NO;
    
    // Set up the main view
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view setOpaque:YES];
    [self.view setBounds:[self _adpativeReferenceBounds]];
    
    // Configure and add the scroll view
    
    _scrollView=[[UIScrollView alloc] initWithFrame:[self _adpativeReferenceBounds]];//initWithFrame:CGRectMake(10, 10, 512, 512)];
    [_scrollView setBackgroundColor:[UIColor darkGrayColor]];
    [_scrollView setClipsToBounds:YES];
    [_scrollView setPagingEnabled:self.pagingEnabled];
    [_scrollView setBounces:self.bounces];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_scrollView setDelegate:self];
    [self.view addSubview:_scrollView];
    
    self.backgroundColor=[UIColor blackColor]; // We setup to black by default
    
}


-(void)viewDidUnload{
    [super viewDidUnload];
    [_scrollView removeFromSuperview];
    _scrollView = nil;
    _backgroundColor=nil;
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
    
    _backgroundColor=nil;
    
}

#pragma mark Look and feel


-(void)setBackgroundColor:(UIColor *)backgroundColor{
    _scrollView.backgroundColor=backgroundColor;
    [self.view setBackgroundColor:backgroundColor];
    _backgroundColor=backgroundColor;
}

-(void)setPagingEnabled:(BOOL)pagingEnabled{
    [_scrollView setPagingEnabled:pagingEnabled];
    _pagingEnabled=pagingEnabled;
}

-(void)setBounces:(BOOL)bounces{
    [_scrollView setBounces:bounces];
    _bounces=bounces;
}



#pragma mark -
#pragma mark Rect and Bounds


-(CGRect)_referenceBounds{
    if(self.view.superview && ![self.view.superview isMemberOfClass:[UIWindow class]]){
        return  self.view.superview.bounds;
    }else{
        return [[UIScreen mainScreen] applicationFrame];
    }
}

-(CGRect)_adpativeReferenceBounds{
    return [self _adaptRect:[self _referenceBounds]];;
}

-(CGRect)_rectRotate:(CGRect)rect{
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
}

-(CGRect)_adaptRect:(CGRect)rect{
    if(self.view.superview && ![self.view.superview isMemberOfClass:[UIWindow class]]){
        return rect;
    }else{
        return [self _isLandscapeOrientation]?[self _rectRotate:rect]:rect;
    }
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
    // Let's be parcimonious
    // We do prepare only if necessary
    // As it produces a view controller reconfiguration.
    if(![self _pageIsPreparedAt:newIndex]){
        if (! (newIndex >= [self.dataSource pageCount]) ){
            
            UIViewController * __weak controller=[self.dataSource viewControllerForIndex:newIndex];
            NSString *identifier=NSStringFromClass([controller class]);
            
            // Update the registry
            [self _register:controller
                    atIndex:newIndex];
            
            // Add the view controller if ncessary
            [self _addIfNecessaryViewController:controller
                                 withIdentifier:identifier];
            
            // Position in the scrollview
            [self _positionViewFrom:controller
                            atIndex:newIndex];
            
            WATTLog(@"Preparing index : %i [%@]" ,newIndex,controller);
            
        }
    }else{
        WATTLog(@"No necessity to prepare : %i",newIndex);
        return ;
    }
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
    if(self.direction==WATTSlidingDirectionHorizontal){
        pageFrame.origin.y = 0;
        CGFloat x=[self _adpativeReferenceBounds].size.width * (CGFloat)index;
        pageFrame.origin.x = x;
    }else{
        pageFrame.origin.x = 0;
        CGFloat y=[self _adpativeReferenceBounds].size.height * (CGFloat)index;
        pageFrame.origin.y = y;
    }
    controller.view.frame = pageFrame;
}

-(void)_register:(UIViewController*)viewController
         atIndex:(NSUInteger)index {
    NSUInteger idx=[_indexes indexOfObject:viewController];
    if(idx!=index){
        if(idx!=NSNotFound){
            // We place a NSNull object reference to the previous index
            [_indexes replaceObjectAtIndex:idx
                                withObject:[NSNull null]];
        }
        //We place a reference viewController at its new index.
        if(index>=[_indexes count]){
            [_indexes addObject:viewController];
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

-(BOOL)_pageIsPreparedAt:(NSUInteger)index{
    if([_indexes count]>index){
        if([_indexes objectAtIndex:index] &&
           [[_indexes objectAtIndex:index]class]!=[NSNull class]){
            return YES;
        }
    }
    return NO;
}


-(BOOL)_pageIsVisibleAt:(NSUInteger)index{
    if([self _pageIsPreparedAt:index]){
        UIViewController *__weak child=(UIViewController*)[_indexes objectAtIndex:index];
        return CGRectIntersectsRect(_scrollView.bounds,child.view.frame);
    }
    return NO;
}




#pragma mark -

-(void)populate{
    _scrollView.contentSize=[self _scrollViewContentSize];
    _scrollView.contentOffset = CGPointMake(0, 0);
    _pageIndex=_futureIndex=0;
    [self _preparePageAtIndex:0];
}


-(CGSize)_scrollViewContentSize{
    NSInteger minPageCount = [self.dataSource pageCount];
    if (minPageCount == 0){
        minPageCount = 1;
    }
    if(self.direction==WATTSlidingDirectionHorizontal){
        return CGSizeMake(_scrollView.frame.size.width * minPageCount,_scrollView.frame.size.height);
    }else{
        return CGSizeMake(_scrollView.frame.size.width,_scrollView.frame.size.height* minPageCount);
    }
}




-(void)nextPageAnimated:(BOOL)animated;{
    _pageIndex++;
    [self goToPage:_pageIndex animated:animated];
}


-(void)previousPageAnimated:(BOOL)animated{
    _pageIndex++;
    [self goToPage:_pageIndex animated:animated];
}


-(void)goToPage:(NSUInteger)index
       animated:(BOOL)animated{
    _pageIndex=index;
    _futureIndex=index;
    [self _preparePageAtIndex:index];
    BOOL horizontal=(self.direction==WATTSlidingDirectionHorizontal);
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.frame.size.width * ((horizontal)?index:0.f),
                                                _scrollView.frame.size.height * ((!horizontal)?index:0.f),
                                                _scrollView.frame.size.width,
                                                _scrollView.frame.size.height)
                            animated:animated];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender{
    
    CGFloat fractionalPage;
    if(self.direction==WATTSlidingDirectionHorizontal){
        fractionalPage  =  _scrollView.contentOffset.x /  _scrollView.frame.size.width;
    }else{
        fractionalPage  =  _scrollView.contentOffset.y /  _scrollView.frame.size.height;
    }
    
    [self _computePageIndexWithPageIndex:fractionalPage];
    
    if(![self _pageIsPreparedAt:_pageIndex])
        [self _preparePageAtIndex:_pageIndex];
    if(![self _pageIsPreparedAt:_futureIndex])
        [self _preparePageAtIndex:_futureIndex];
    
}


-(void)_computePageIndexWithPageIndex:(CGFloat)page{
    
    if(page<0.f)
        page=0.f;
    
    NSUInteger roundedDown=(NSUInteger)floorf(page); // ceilf rounded Up
    _pageIndex=roundedDown;
    
    if(page<(CGFloat)_pageIndex){
        _futureIndex=roundedDown;
    }
    if(page>(CGFloat)_pageIndex && roundedDown<[self.dataSource pageCount]-1){
        _futureIndex=roundedDown+1;
    }
    
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
    
    CGSize newContentSize=[self _scrollViewContentSize];
    // If the contentsize should change
    if(!CGSizeEqualToSize(newContentSize,  _scrollView.contentSize)){
        // Reset the scroll view content size
        _scrollView.contentSize=newContentSize;
        // And reposition the controllers
        NSUInteger i=0;
        for (UIViewController *controller in _indexes) {
            if(controller && ![controller isMemberOfClass:[NSNull class]]){
                [self _positionViewFrom:controller
                                atIndex:i];
            }
            i++;
        }
        [self goToPage:_pageIndex animated:NO];
    }
}


@end