//
//  WATTItemViewController.h
//  WattPagingContainer
//
//  Created by Benoit Pereira da Silva on 17/02/13.
//  Copyright (c) 2013 Pereira da Silva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WATTPagesController.h"
#import "WATTItemModel.h"

@interface WATTItemViewController : UIViewController<WATTPageProtocol>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
