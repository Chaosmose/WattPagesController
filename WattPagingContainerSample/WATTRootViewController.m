//
//  WATTRootViewController.m
//  WattPagingContainer
//
//  Created by Benoit Pereira da Silva on 15/02/13.
//  Copyright (c) 2013 https://github.com/benoit-pereira-da-silva/
//  http://www.pereira-da-silva.com

// This file is part of WattPagingContainer
//
// WattPagingContainer is free software: you can redistribute it and/or modify
// it under the terms of the GNU LESSER GENERAL PUBLIC LICENSE as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// WattPagingContainer is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU LESSER GENERAL PUBLIC LICENSE for more details.

// You should have received a copy of the GNU LESSER GENERAL PUBLIC LICENSE
// along with WattPagingContainer  If not, see <http://www.gnu.org/licenses/>

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
    [self populateAndGoToIndex:0
                      animated:NO];
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