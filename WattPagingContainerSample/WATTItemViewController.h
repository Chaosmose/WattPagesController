//
//  WATTItemViewController.h
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



#import <UIKit/UIKit.h>
#import "WATTPagesController.h"
#import "WATTItemModel.h"

@interface WATTItemViewController : UIViewController<WATTPageProtocol>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
