//
//  WATTItemViewController.m
//  WattPagingContainer
//
//  Created by Benoit Pereira da Silva on 17/02/13.
//  Copyright (c) 2013 Pereira da Silva. All rights reserved.
//

#import "WATTItemViewController.h"

@interface WATTItemViewController ()

@end

@implementation WATTItemViewController{
    WATTItemModel *_currentModel;
}


- (void)viewDidUnload {
    [self setImageView:nil];
    _currentModel=nil;
    [super viewDidUnload];
}


-(void)configureWithModel:(id)model{
    if([model isKindOfClass:[WATTItemModel class]]){
        _currentModel=(WATTItemModel*)model;
        [self.imageView setImage:[UIImage imageNamed:_currentModel.imageName]];
    }else{
        // We prefer to be strongly typed
        // So we accept only a specific model.
        [NSException raise:@"WATTPageProtocol Model inconsistency"
                    format:@"Model should be a WATTItemModel and is currently %@",NSStringFromClass([model class])];
    }
}


#pragma mark -
#pragma mark Debug facility


-(NSString*)description{
    return [NSString stringWithFormat:@"%@ %@", NSStringFromClass([self class]),_currentModel.imageName];
}


@end
