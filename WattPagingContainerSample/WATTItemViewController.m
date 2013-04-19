//
//  WATTItemViewController.m
//  WattPagingContainer
//
//  Created by Benoit Pereira da Silva on 17/02/13.
//  Copyright (c) 2013 Pereira da Silva. All rights reserved.
//

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
