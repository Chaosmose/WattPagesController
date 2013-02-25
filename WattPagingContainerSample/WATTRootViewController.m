//
//  WATTRootViewController.m
//  WattPagingContainer
//
//  Created by Benoit Pereira da Silva on 15/02/13.
//  Copyright (c) 2013 https://github.com/benoit-pereira-da-silva/
//  http://www.pereira-da-silva.com

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
#import "WATTRootViewController.h"


@interface WATTRootViewController ()

@end

@implementation WATTRootViewController{
    NSMutableArray *_listOfItem;
}

#pragma mark - life cycle

-(void)viewDidLoad{
    [super viewDidLoad];
    self.dataSource=self;
    self.direction=WATTSlidingDirectionHorizontal;
    self.backgroundColor=[UIColor blackColor];
    self.bounces=YES;
    [self _loadItems]; // Load the data
    [self populate];
    [self goToPage:0
          animated:YES];
}

#pragma mark - data

-(void)_loadItems{
    
    if(!_listOfItem){
        _listOfItem=[NSMutableArray array];
                
        for (int i=0; i<4;i++) {
            [self _addItemForIndex:i];
        }
        
        NSURL *url=[[NSBundle mainBundle] URLForResource:@"Data" withExtension:@"plist"];
        NSArray*list=[NSArray arrayWithContentsOfURL:url];
        for (NSString* stringUrl in list) {
            [self _addItemWithURL:[NSURL URLWithString:stringUrl]];
        }
    }
}


-(void)_addItemForIndex:(NSInteger)index{
    WATTItemModel *model=[WATTItemModel alloc];
    model.imageName=[NSString stringWithFormat:@"nombres.00%i.jpg",index];
    [_listOfItem insertObject:model atIndex:index];
}


-(void)_addItemWithURL:(NSURL*)url{
    WATTWebModel *model=[[WATTWebModel alloc] init];
    model.url=url;
    [_listOfItem addObject:model];
}

-(id)_modelAtIndex:(NSUInteger)index{
    return [_listOfItem objectAtIndex:index];
}



-(void)pageIndexDidChange:(NSUInteger)pageIndex{
    //A sample of dynamic injection
    //
    if(pageIndex==3){
        if(![[self _modelAtIndex:4] isKindOfClass:[WATTItemModel class]]){
            [self _addItemForIndex:4];
            //[self populate];
        }
    }
}


#pragma mark -
#pragma mark WATTPagingDataSource


-(UIViewController*)viewControllerForIndex:(NSUInteger)index{
    
    
    if([[self _modelAtIndex:index] isKindOfClass:[WATTItemModel class]]){
        
        // 1- We try to reuse an existing viewController
        WATTItemViewController*controller=(WATTItemViewController*)[self dequeueViewControllerWithClass:[WATTItemViewController class]];
        
        // 2- If there is no view Controllers we instanciate one.
        if(!controller)
            controller=[[self storyboard] instantiateViewControllerWithIdentifier:@"imagePage"];
        
        // 3- Important : controller.view must be called once
        // So we test it to for the initialization cycle, before to configure
        if(controller.view){
            // 4 - We pass the model to the view Controller.
            [controller configureWithModel:[self _modelAtIndex:index]];
        }
        
        return controller;
    }
    
    if([[self _modelAtIndex:index] isKindOfClass:[WATTWebModel class]]){
        
        // 1- We try to reuse an existing viewController
        WATTWebviewController*controller=(WATTWebviewController*)[self dequeueViewControllerWithClass:[WATTWebviewController class]];
        
        // 2- If there is no view Controllers we instanciate one.
        if(!controller)
            controller=[[self storyboard] instantiateViewControllerWithIdentifier:@"page"];
        
        // 3- Important : controller.view must be called once
        // So we test it to for the initialization cycle, before to configure
        if(controller.view){
            // 4 - We pass the model to the view Controller.
            [controller configureWithModel:[self _modelAtIndex:index]];
        }
        return controller;
        
    }
    
    return nil; 
}


-(NSUInteger)pageCount{
    return _listOfItem.count;
}


- (void)viewDidUnload {
    [self setPreviousButton:nil];
    [self setNextButton:nil];
    [super viewDidUnload];
}

#pragma mark - Actions

- (IBAction)previous:(id)sender {
    [self previousPageAnimated:YES];
}

- (IBAction)next:(id)sender {
   [self nextPageAnimated:YES];
}



@end