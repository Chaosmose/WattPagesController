//
//  WATTRootViewController.h
//  WattPagingContainer
//
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


#import "WATTPagesController.h"
#import "WATTWebviewController.h"
#import "WATTWebModel.h"
#import "WATTItemViewController.h"
#import "WATTItemModel.h"

@interface WATTRootViewController : WATTPagesController<WATTPagingDataSource>

@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)previous:(id)sender;
- (IBAction)next:(id)sender;

@end